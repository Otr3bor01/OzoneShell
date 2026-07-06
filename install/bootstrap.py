#Currently made with AI as a test.

#!/usr/bin/env python3
"""
bootstrap.py — setup iniziale del progetto Ozone.

Cosa fa:
  1. Rileva il numero di monitor collegati (per decidere la modalità workspace)
  2. Rileva la presenza di una batteria (per abilitare/disabilitare widget)
  3. Scrive state/system.toml con questi dati (fonte di verità condivisa
     tra Python, Hyprland/Lua e Quickshell/QML)
  4. Crea i symlink dal repo verso ~/.config/*, facendo backup di eventuali
     file/cartelle preesistenti invece di sovrascriverli alla cieca

Va eseguito una sola volta all'installazione (o ogni volta che si aggiunge
un nuovo "target" da linkare). Idempotente: rieseguirlo non rompe nulla.
"""

from __future__ import annotations

import json
import shutil
import subprocess
from datetime import datetime
from pathlib import Path

# ============================================================
# CONFIGURAZIONE
# ============================================================

REPO_ROOT = Path(__file__).resolve().parent.parent  # install/ -> repo root
STATE_DIR = REPO_ROOT / "state"

# sorgente (nel repo) -> destinazione (in ~/.config)
LINKS: dict[Path, Path] = {
    REPO_ROOT / "hypr": Path("~/.config/hypr").expanduser(),
    REPO_ROOT / "kitty": Path("~/.config/kitty").expanduser(),
    REPO_ROOT / "shell": Path("~/.config/quickshell/ozone").expanduser(),
}


# ============================================================
# DETECTION
# ============================================================

def detect_monitors() -> int:
    """Numero di monitor collegati. Prova hyprctl (se Hyprland è già up),
    altrimenti fa fallback sullo stato del DRM in /sys."""
    try:
        out = subprocess.run(
            ["hyprctl", "monitors", "-j"],
            capture_output=True, text=True, timeout=2, check=True,
        )
        monitors = json.loads(out.stdout)
        return len(monitors)
    except (FileNotFoundError, subprocess.CalledProcessError,
            subprocess.TimeoutExpired, json.JSONDecodeError):
        pass

    # Fallback: leggi /sys/class/drm/card*-*/status
    drm = Path("/sys/class/drm")
    if not drm.exists():
        return 1  # non possiamo saperlo, assumiamo un solo schermo

    connected = 0
    for status_file in drm.glob("card*-*/status"):
        try:
            if status_file.read_text().strip() == "connected":
                connected += 1
        except OSError:
            continue
    return connected or 1


def detect_battery() -> bool:
    """True se esiste almeno un device BAT* in power_supply."""
    power_supply = Path("/sys/class/power_supply")
    if not power_supply.exists():
        return False
    return any(power_supply.glob("BAT*"))


# ============================================================
# STATE
# ============================================================

def write_system_state(monitors: int, has_battery: bool) -> Path:
    STATE_DIR.mkdir(parents=True, exist_ok=True)
    path = STATE_DIR / "system.toml"
    content = (
        "# Generato da install/bootstrap.py — non modificare a mano\n"
        "[system]\n"
        f"monitors = {monitors}\n"
        f"has_battery = {'true' if has_battery else 'false'}\n"
    )
    path.write_text(content)
    return path


# ============================================================
# SYMLINKING
# ============================================================

def backup_path(target: Path) -> Path:
    timestamp = datetime.now().strftime("%Y%m%d-%H%M%S")
    return target.with_name(f"{target.name}.backup-{timestamp}")


def create_symlink(source: Path, target: Path) -> str:
    """Crea target -> source. Ritorna una stringa di stato leggibile."""
    if not source.exists():
        return f"⚠️  saltato: {source} non esiste nel repo"

    target.parent.mkdir(parents=True, exist_ok=True)

    if target.is_symlink():
        if target.resolve() == source.resolve():
            return f"✓  già collegato: {target}"
        target.unlink()
    elif target.exists():
        bak = backup_path(target)
        shutil.move(str(target), str(bak))
        print(f"   backup creato: {target} -> {bak}")

    target.symlink_to(source, target_is_directory=source.is_dir())
    return f"✓  collegato: {target} -> {source}"


# ============================================================
# MAIN
# ============================================================

def main() -> None:
    print("== Ozone bootstrap ==\n")

    print("[1/3] Detection hardware")
    monitors = detect_monitors()
    has_battery = detect_battery()
    print(f"   monitor rilevati : {monitors}")
    print(f"   batteria presente: {has_battery}")

    print("\n[2/3] Scrittura state/system.toml")
    state_path = write_system_state(monitors, has_battery)
    print(f"   scritto in: {state_path}")

    print("\n[3/3] Creazione symlink")
    for source, target in LINKS.items():
        print(f"   {create_symlink(source, target)}")

    print("\nFatto. Esegui setTheme.py per generare il primo tema attivo.")


if __name__ == "__main__":
    main()