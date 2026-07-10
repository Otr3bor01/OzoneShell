#currently AI made

#!/usr/bin/env python3
"""
generateThemeIndex.py

Genera state/themeIndex.json con le info basilari (nome, simbolo, fontFamily,
background, foreground) di tutti i temi disponibili, leggendo i file .toml
nella cartella dei temi.

Rispetta $XDG_CONFIG_HOME (fallback ~/.config), coerente con Paths.qml
lato QML (StandardPaths.ConfigLocation).
"""

import os
import sys
import json
from pathlib import Path

if sys.version_info < (3, 11):
    sys.exit("Serve Python 3.11+ per tomllib (stdlib). Versione attuale: "
              f"{sys.version_info.major}.{sys.version_info.minor}")

import tomllib


def get_config_dir() -> Path:
    """Equivalente Python di StandardPaths.ConfigLocation."""
    xdg_config_home = os.environ.get("XDG_CONFIG_HOME")
    if xdg_config_home:
        return Path(xdg_config_home) / "quickshell"
    return Path.home() / ".config" / "quickshell"


# state/ vive nel config utente (raggiunto anche via symlink da ~/.config/quickshell)
CONFIG_DIR = get_config_dir()
STATE_DIR = CONFIG_DIR / "state"

# themes/ invece vive nel repo stesso (OzoneShell/themes), non in ~/.config.
# Questo script sta in OzoneShell/scripts/, quindi risalgo di un livello
# in più rispetto alla cartella dello script per arrivare alla root del repo.
REPO_ROOT = Path(__file__).resolve().parent.parent
THEMES_DIR = REPO_ROOT / "themes"

OUTPUT_FILE = STATE_DIR / "themeIndex.json"


def extract_basic_info(theme_path: Path) -> dict:
    with open(theme_path, "rb") as f:
        data = tomllib.load(f)

    fonts = data.get("fonts", {})
    colors_special = data.get("colors", {}).get("special", {})

    def normalize_color(value: str) -> str:
        """Garantisce che i colori abbiano sempre il prefisso '#'."""
        if value and not value.startswith("#"):
            return f"#{value}"
        return value or ""

    # Il nome del tema è la cartella che contiene theme.toml
    # (es. themes/crimson/theme.toml -> "crimson"), usato come fallback/id.
    theme_dir_name = theme_path.parent.name

    return {
        "name": data.get("theme_name", theme_dir_name),
        "symbol": data.get("theme_symbol", ""),
        "fontFamily": fonts.get("family", ""),
        "background": normalize_color(colors_special.get("background", "")),
        "foreground": normalize_color(colors_special.get("foreground", "")),
        "file": theme_dir_name,
    }


def main():
    if not THEMES_DIR.exists():
        sys.exit(f"Cartella temi non trovata: {THEMES_DIR}")

    theme_files = sorted(THEMES_DIR.glob("*/theme.toml"))
    if not theme_files:
        sys.exit(f"Nessun file .toml trovato in: {THEMES_DIR}")

    themes = []
    for theme_path in theme_files:
        try:
            themes.append(extract_basic_info(theme_path))
        except Exception as e:
            print(f"Attenzione: errore nel tema '{theme_path.name}': {e}", file=sys.stderr)

    STATE_DIR.mkdir(parents=True, exist_ok=True)
    OUTPUT_FILE.write_text(json.dumps({"themes": themes}, indent=2, ensure_ascii=False))

    print(f"Indice generato: {OUTPUT_FILE}")
    print(f"Temi trovati: {len(themes)}")


if __name__ == "__main__":
    main()