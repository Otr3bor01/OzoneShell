from __future__ import annotations
from pathlib import Path
import json
import subprocess
import sys
import tomllib
from typing import Any

#1: detect activation when the new theme is chosen (triggered probably from quickshell or hyprland. We will call these programs "Selectors")
#2: read the current_theme file (generated from the selector)
#3: find the theme.toml
#4: read the theme.toml parameters
#5: generate a coherent config file for every program (quickshell, hyprland, cava, kitty, thunar, ecc)
#6: place this file as a placeholder as "activeTheme"

#=============================
#=======Defining PATHS========
#=============================
REPO_ROOT = Path(__file__).resolve().parent.parent
THEMES_DIR = REPO_ROOT / "themes"
THEME_NAME_PATH = REPO_ROOT / "state" / "active_theme"

HYPR_OUTPUT = REPO_ROOT / "hypr" / "state" / "theme.lua"
KITTY_OUTPUT = REPO_ROOT / "kitty" / "state" / "theme.conf"
QUICKSHELL_OUTPUT = REPO_ROOT / "shell" / "state" / "theme.json"


#================================
#======READ CURRENT_THEME========
#================================
def readCurrentTheme() -> str:
    with open(THEME_NAME_PATH) as f:
        current_theme = f.read()
    return current_theme.strip()


def writeCurrentTheme(theme_name: str) -> None:
    THEME_NAME_PATH.parent.mkdir(parents=True, exist_ok=True)
    THEME_NAME_PATH.write_text(theme_name)


# NB: THEME_PATH va calcolato DOPO aver definito readCurrentTheme(),
# altrimenti la funzione non esiste ancora quando questa riga viene letta.
# Meglio ancora: calcolarlo dentro main(), così lo script non fallisce
# all'avvio se active_theme non esiste ancora (prima esecuzione).
def resolveThemePath(theme_name: str) -> Path:
    if not theme_name.isidentifier():
        raise ValueError(f"Nome tema non valido: {theme_name!r}")
    path = THEMES_DIR / theme_name / "theme.toml"
    if not path.is_file():
        raise FileNotFoundError(f"Tema non trovato: {path}")
    return path


def loadTheme(theme_path: Path) -> dict[str, Any]:
    with open(theme_path, "rb") as f:
        return tomllib.load(f)


#================================
#============HYPRLAND============
#================================
##------------
##Naming maps:
##------------
COLOR_GROUP_SUFFIX = {
    "normal": "N",
    "bright": "B",
}
SPECIAL_COLOR_MAP = {
    "background": "backgroundColor",
    "foreground": "foregroundColor",
    "icons": "iconsColor",
}
HYPRLAND_KEY_MAP = {
    "gaps_in": "gapsIn",
    "gaps_out": "gapsOut",
    "border_size": "borderSize",
    "layout": "layoutType",
    "angle": "angle",
}


def luaValue(value: Any) -> str:
    if isinstance(value, str):
        return '"' + value.replace('"', '\\"') + '"'
    if isinstance(value, bool):
        return "true" if value else "false"
    return str(value)


def colorRefToLuaName(ref: str) -> str:
    """'colors.normal.purple' (con o senza '@' iniziale) -> 'purpleN'"""
    ref = ref.lstrip("@")
    parts = ref.split(".")
    if len(parts) != 3 or parts[0] != "colors":
        raise ValueError(f"Riferimento colore non riconosciuto: {ref}")

    _, group, name = parts
    if group in COLOR_GROUP_SUFFIX:
        return f"{name}{COLOR_GROUP_SUFFIX[group]}"
    if group == "special":
        return SPECIAL_COLOR_MAP[name]
    raise ValueError(f"Gruppo colore sconosciuto: {group}")


def generateHyprlandLua(theme: dict[str, Any]) -> str:
    colors = theme.get("colors", {})
    hypr_general = theme.get("hyprland", {}).get("general", {})

    lines = ["-- Generato da scripts/setTheme.py — non modificare a mano", "local theme = {"]

    for group, suffix in COLOR_GROUP_SUFFIX.items():
        for name, value in colors.get(group, {}).items():
            lines.append(f"    {name}{suffix} = {luaValue(value)},")

    for name, lua_name in SPECIAL_COLOR_MAP.items():
        if name in colors.get("special", {}):
            lines.append(f"    {lua_name} = {luaValue(colors['special'][name])},")

    for toml_key, lua_name in HYPRLAND_KEY_MAP.items():
        if toml_key in hypr_general:
            lines.append(f"    {lua_name} = {luaValue(hypr_general[toml_key])},")

    lines.append("}")

    gradient_lines = ["--gradient using preexistent colors"]
    for gradient_key, lua_field in (
        ("active_gradient", "activeGradient"),
        ("inactive_gradient", "inactiveGradient"),
    ):
        if gradient_key in hypr_general:
            refs = hypr_general[gradient_key]
            lua_refs = ", ".join(f"theme.{colorRefToLuaName(r)}" for r in refs)
            gradient_lines.append(f"theme.{lua_field} = {{{lua_refs}}}")

    return "\n".join(lines) + "\n" + "\n".join(gradient_lines) + "\n--\nreturn theme\n"


#================================
#=============KITTY==============
#================================
KITTY_ANSI_MAP = {
    "black": 0, "red": 1, "green": 2, "yellow": 3,
    "blue": 4, "purple": 5, "pink": 6, "white": 7,
}


def generateKittyConf(theme: dict[str, Any]) -> str:
    colors = theme.get("colors", {})
    normal = colors.get("normal", {})
    bright = colors.get("bright", {})
    special = colors.get("special", {})
    font = theme.get("font", {})
    cursor = theme.get("tui", {}).get("cursor", {})
    window = theme.get("tui", {}).get("window", {})

    lines = ["# Generato da scripts/setTheme.py — non modificare a mano"]

    if special.get("background"):
        lines.append(f"background {special['background']}")
    if special.get("foreground"):
        lines.append(f"foreground {special['foreground']}")

    for name, idx in KITTY_ANSI_MAP.items():
        if name in normal:
            lines.append(f"color{idx} {normal[name]}")
        if name in bright:
            lines.append(f"color{idx + 8} {bright[name]}")

    if font.get("family"):
        lines.append(f"font_family {font['family']}")
    if font.get("size"):
        lines.append(f"font_size {font['size']}")

    if cursor.get("shape"):
        lines.append(f"cursor_shape {cursor['shape']}")
    if cursor.get("beam_thickness"):
        lines.append(f"cursor_beam_thickness {cursor['beam_thickness']}")
    if cursor.get("blink_interval") is not None:
        lines.append(f"cursor_blink_interval {cursor['blink_interval']}")

    if window.get("opacity") is not None:
        lines.append(f"background_opacity {window['opacity']}")

    return "\n".join(lines)


#================================
#===========QUICKSHELL============
#================================
def resolveColorRef(theme: dict[str, Any], ref: str) -> str:
    """Risolve 'colors.normal.purple' nel valore esadecimale reale,
    camminando dentro il dict del tema."""
    ref = ref.lstrip("@")
    value: Any = theme
    for key in ref.split("."):
        value = value[key]
    return value


def generateQuickshellJson(theme: dict[str, Any]) -> str:
    """Quickshell legge JSON: passiamo il tema con i gradienti già
    risolti in valori esadecimali (così QML non deve capire i riferimenti)."""
    resolved = json.loads(json.dumps(theme))  # deep copy semplice
    hypr_general = resolved.get("hyprland", {}).get("general", {})
    for key in ("active_gradient", "inactive_gradient"):
        if key in hypr_general:
            hypr_general[key] = [resolveColorRef(theme, r) for r in hypr_general[key]]
    return json.dumps(resolved, indent=2, ensure_ascii=False)


#================================
#============SCRITTURA============
#================================
def writeStateFile(path: Path, content: str) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(content + "\n")


def triggerReload() -> None:
    try:
        subprocess.run(["hyprctl", "reload"], check=True, timeout=2)
        print("   hyprctl reload inviato")
    except (FileNotFoundError, subprocess.CalledProcessError, subprocess.TimeoutExpired):
        print("   ⚠️  hyprctl reload non riuscito (Hyprland non attivo?)")
    # TODO: IPC verso Quickshell per far ricaricare il FileView del tema


#================================
#===============MAIN==============
#================================
def main() -> None:
    if len(sys.argv) > 1:
        theme_name = sys.argv[1]
        writeCurrentTheme(theme_name)
    else:
        theme_name = readCurrentTheme()

    print(f"== Applico tema: {theme_name} ==\n")

    theme_path = resolveThemePath(theme_name)
    theme = loadTheme(theme_path)

    print("[1/4] Generazione hyprland (lua)")
    writeStateFile(HYPR_OUTPUT, generateHyprlandLua(theme))
    print(f"      scritto in {HYPR_OUTPUT}")

    print("[2/4] Generazione kitty (conf)")
    writeStateFile(KITTY_OUTPUT, generateKittyConf(theme))
    print(f"      scritto in {KITTY_OUTPUT}")

    print("[3/4] Generazione quickshell (json)")
    writeStateFile(QUICKSHELL_OUTPUT, generateQuickshellJson(theme))
    print(f"      scritto in {QUICKSHELL_OUTPUT}")

    print("[4/4] Reload")
    triggerReload()

    print("\nFatto.")


if __name__ == "__main__":
    main()