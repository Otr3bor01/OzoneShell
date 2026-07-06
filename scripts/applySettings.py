#currently AI made!

#!/usr/bin/env python3
"""
applySettings.py — applica le impostazioni utente ai programmi.

Flusso:
  1. Legge settings/schema.json (definizione delle opzioni valide)
  2. Legge state/settings.json (scelte attuali, scritte dal client settings)
  3. Valida ogni valore contro lo schema
  4. Genera:
     - hypr/state/settings.lua   (per Hyprland)
     - shell/state/settings.json (per Quickshell)
  5. Prova a segnalare il reload

Uso:
    python applySettings.py            # applica lo stato attuale
    python applySettings.py --check    # valida solo, non scrive nulla
"""

from __future__ import annotations

import json
import subprocess
import sys
from pathlib import Path
from typing import Any

# ============================================================
# PATH
# ============================================================

REPO_ROOT = Path(__file__).resolve().parent.parent

SCHEMA_PATH = REPO_ROOT / "settings" / "schema.json"
SETTINGS_STATE_PATH = REPO_ROOT / "state" / "settings.json"

HYPR_OUTPUT = REPO_ROOT / "hypr" / "state" / "settings.lua"
QUICKSHELL_OUTPUT = REPO_ROOT / "shell" / "state" / "settings.json"


# ============================================================
# LETTURA / VALIDAZIONE
# ============================================================

def load_json(path: Path) -> dict[str, Any]:
    if not path.is_file():
        raise FileNotFoundError(f"File non trovato: {path}")
    with open(path) as f:
        return json.load(f)


def validate_settings(settings: dict[str, Any], schema: dict[str, Any]) -> list[str]:
    """Ritorna una lista di errori (vuota se tutto valido)."""
    errors: list[str] = []

    for key, value in settings.items():
        if key not in schema:
            errors.append(f"Chiave sconosciuta nello schema: '{key}'")
            continue

        rule = schema[key]
        if rule["type"] == "enum":
            if value not in rule["options"]:
                errors.append(
                    f"'{key}': valore '{value}' non valido, opzioni: {rule['options']}"
                )
        elif rule["type"] == "boolean":
            if not isinstance(value, bool):
                errors.append(f"'{key}': atteso booleano, ricevuto {type(value).__name__}")
        else:
            errors.append(f"'{key}': tipo di schema sconosciuto '{rule['type']}'")

    for key, rule in schema.items():
        if key not in settings:
            errors.append(f"Chiave mancante nello stato, userò il default: '{key}' = {rule['default']}")

    return errors


def sanitize_settings(settings: dict[str, Any], schema: dict[str, Any]) -> dict[str, Any]:
    """Per ogni chiave dello schema: usa il valore fornito se valido,
    altrimenti ricade sul default. Non propaga mai un valore invalido."""
    clean: dict[str, Any] = {}
    for key, rule in schema.items():
        value = settings.get(key, rule["default"])

        if rule["type"] == "enum" and value not in rule["options"]:
            value = rule["default"]
        elif rule["type"] == "boolean" and not isinstance(value, bool):
            value = rule["default"]

        clean[key] = value
    return clean


# ============================================================
# GENERATORI
# ============================================================

def lua_value(value: Any) -> str:
    if isinstance(value, bool):
        return "true" if value else "false"
    if isinstance(value, str):
        return '"' + value.replace('"', '\\"') + '"'
    return str(value)


def generate_hyprland_lua(settings: dict[str, Any]) -> str:
    lines = ["-- Generato da scripts/applySettings.py — non modificare a mano", "return {"]
    for key, value in settings.items():
        lines.append(f"    {key} = {lua_value(value)},")
    lines.append("}")
    return "\n".join(lines)


def generate_quickshell_json(settings: dict[str, Any]) -> str:
    return json.dumps(settings, indent=2, ensure_ascii=False)


# ============================================================
# SCRITTURA / RELOAD
# ============================================================

def write_state_file(path: Path, content: str) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(content + "\n")


def trigger_reload() -> None:
    try:
        subprocess.run(["hyprctl", "reload"], check=True, timeout=2)
        print("   hyprctl reload inviato")
    except (FileNotFoundError, subprocess.CalledProcessError, subprocess.TimeoutExpired):
        print("   ⚠️  hyprctl reload non riuscito (Hyprland non attivo?)")
    # TODO: IPC verso Quickshell per notificare il cambio impostazioni


# ============================================================
# MAIN
# ============================================================

def main() -> None:
    check_only = "--check" in sys.argv

    schema = load_json(SCHEMA_PATH)
    raw_settings = load_json(SETTINGS_STATE_PATH)

    errors = validate_settings(raw_settings, schema)
    if errors:
        print("Problemi trovati nelle impostazioni:")
        for e in errors:
            print(f"  - {e}")

    settings = sanitize_settings(raw_settings, schema)

    if check_only:
        print("\n--check: nessun file scritto.")
        return

    print("\n[1/2] Generazione hyprland (lua)")
    write_state_file(HYPR_OUTPUT, generate_hyprland_lua(settings))
    print(f"      scritto in {HYPR_OUTPUT}")

    print("[2/2] Generazione quickshell (json)")
    write_state_file(QUICKSHELL_OUTPUT, generate_quickshell_json(settings))
    print(f"      scritto in {QUICKSHELL_OUTPUT}")

    print("\nReload")
    trigger_reload()

    print("\nFatto.")


if __name__ == "__main__":
    main()