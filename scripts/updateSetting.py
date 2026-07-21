#!/usr/bin/env python3
"""
updateSetting.py — aggiorna una singola impostazione e propaga i cambiamenti

Uso:
    python updateSetting.py audioFeedback "pop"
"""

import json
import subprocess
import sys
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parent.parent
SETTINGS_STATE_PATH = REPO_ROOT / "state" / "settings.json"
APPLY_SETTINGS_SCRIPT = REPO_ROOT / "scripts" / "applySettings.py"

def main():
    if len(sys.argv) < 3:
        print("Uso: updateSetting.py <key> <value>")
        sys.exit(1)
    
    key = sys.argv[1]
    value = sys.argv[2]
    
    # Leggi il file attuale
    if SETTINGS_STATE_PATH.exists():
        with open(SETTINGS_STATE_PATH) as f:
            settings = json.load(f)
    else:
        settings = {}
    
    # Aggiorna il valore
    settings[key] = value
    
    # Scrivi il file aggiornato
    with open(SETTINGS_STATE_PATH, 'w') as f:
        json.dump(settings, f, indent=2)
    
    print(f"Updated {key} = {value}")
    
    # Esegui applySettings.py
    subprocess.run([sys.executable, str(APPLY_SETTINGS_SCRIPT)], check=False)

if __name__ == "__main__":
    main()
