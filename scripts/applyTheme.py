from __future__ import annotations
from pathlib import Path
import json
import re
import subprocess
import sys
import tomllib
from typing import Any, Callable

#1: detect activation when the new theme is chosen (triggered probably from quickshell or hyprland. We will call these programs "Selectors")
#2: read the current_theme file (generated from the selector)
#3: find the theme.toml
#4: read the theme.toml parameters
#5: risolvere UNA SOLA VOLTA tutti i riferimenti "@" in valori reali
#6: generare un config coerente per ogni programma (quickshell, hyprland, kitty, fuzzel, cava, fastfetch)
#7: scrivere ogni file nel suo state/ e triggerare un reload

#=============================
#=======Defining PATHS========
#=============================
REPO_ROOT = Path(__file__).resolve().parent.parent
THEMES_DIR = REPO_ROOT / "themes"
THEME_NAME_PATH = REPO_ROOT / "state" / "active_theme"

HYPR_OUTPUT       = REPO_ROOT / "hypr"      / "state" / "theme.lua"
KITTY_OUTPUT      = REPO_ROOT / "kitty"     / "state" / "theme.conf"
QUICKSHELL_OUTPUT = REPO_ROOT / "shell"     / "state" / "theme.json"
FUZZEL_OUTPUT     = REPO_ROOT / "fuzzel"    / "state" / "theme.ini"
CAVA_OUTPUT       = REPO_ROOT / "cava"      / "state" / "theme.conf"
FASTFETCH_OUTPUT  = REPO_ROOT / "fastfetch" / "state" / "theme.jsonc"


#================================
#======READ CURRENT_THEME========
#================================
def readCurrentTheme() -> str:
    with open(THEME_NAME_PATH) as f:
        return f.read().strip()


def writeCurrentTheme(theme_name: str) -> None:
    THEME_NAME_PATH.parent.mkdir(parents=True, exist_ok=True)
    THEME_NAME_PATH.write_text(theme_name)


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
#====RISOLUZIONE RIFERIMENTI======
#================================
# Unico punto in cui lo script "capisce" cosa significhi "@colori.normal.purple"
# o "@fonts.family". Ogni generatore, dopo questo passaggio, legge solo valori
# concreti dalla propria sezione — niente più logica di risoluzione duplicata
# sparsa tra Hyprland/Kitty/Quickshell come nella versione precedente.

def getPath(theme: dict[str, Any], dotted_path: str) -> Any:
    value: Any = theme
    for key in dotted_path.split("."):
        value = value[key]
    # Se il valore puntato è a sua volta un riferimento (es. error = "@colors.normal.red"
    # in una catena più lunga), lo risolviamo ricorsivamente.
    if isinstance(value, str) and value.startswith("@"):
        return getPath(theme, value[1:])
    return value


_REF_PATTERN = re.compile(r"@([a-zA-Z_][a-zA-Z0-9_]*(?:\.[a-zA-Z_][a-zA-Z0-9_]*)+)")


def resolveValue(theme: dict[str, Any], value: Any) -> Any:
    if isinstance(value, str) and value.startswith("@") and _REF_PATTERN.fullmatch(value):
        # Caso comune: l'intero valore è un riferimento puro ("@colors.normal.purple")
        return getPath(theme, value[1:])
    if isinstance(value, str) and "@" in value:
        # Caso raro: riferimento incorporato in una stringa più ampia
        # (es. "@fonts.family:size=@fonts.size_normal"). Ogni "@a.b.c" trovato
        # viene sostituito col suo valore risolto, il resto del testo resta invariato.
        def _sub(match: re.Match[str]) -> str:
            return str(getPath(theme, match.group(1)))
        return _REF_PATTERN.sub(_sub, value)
    if isinstance(value, list):
        return [resolveValue(theme, v) for v in value]
    if isinstance(value, dict):
        return {k: resolveValue(theme, v) for k, v in value.items()}
    return value


def resolveTheme(theme: dict[str, Any]) -> dict[str, Any]:
    """Ritorna una copia del tema con ogni '@a.b.c' sostituito dal valore reale."""
    return resolveValue(theme, theme)


#================================
#============HYPRLAND============
#================================
def luaValue(value: Any) -> str:
    if isinstance(value, str):
        return '"' + value.replace('"', '\\"') + '"'
    if isinstance(value, bool):
        return "true" if value else "false"
    return str(value)


def luaTable(values: list[Any]) -> str:
    return "{" + ", ".join(luaValue(v) for v in values) + "}"


def generateHyprlandLua(theme: dict[str, Any]) -> str:
    """theme è già risolto: basta leggere theme['hyprland'] più i colori speciali
    (bordo/sfondo) usati direttamente dal compositor."""
    hypr = theme.get("hyprland", {})
    special = theme.get("colors", {}).get("special", {})

    lines = ["-- Generato da scripts/applyTheme.py — non modificare a mano", "local theme = {"]

    for key, value in hypr.items():
        if isinstance(value, list):
            lines.append(f"    {key} = {luaTable(value)},")
        else:
            lines.append(f"    {key} = {luaValue(value)},")

    for key, value in special.items():
        lines.append(f"    {key} = {luaValue(value)},")

    lines.append("}")
    lines.append("return theme")
    return "\n".join(lines) + "\n"


#================================
#=============KITTY==============
#================================
# La chiave TOML e la chiave di kitty.conf coincidono quasi sempre; le poche
# eccezioni (window_opacity -> background_opacity, window_blur -> background_blur
# per fork patchati) sono elencate qui.
KITTY_KEY_OVERRIDES = {
    "window_opacity": "background_opacity",
    "window_blur": "background_blur",
}
KITTY_SKIP_KEYS = set()  # eventuali chiavi da NON scrivere in kitty.conf


def generateKittyConf(theme: dict[str, Any]) -> str:
    kitty = theme.get("kitty", {})
    lines = ["# Generato da scripts/applyTheme.py — non modificare a mano"]

    for key, value in kitty.items():
        if key in KITTY_SKIP_KEYS:
            continue
        conf_key = KITTY_KEY_OVERRIDES.get(key, key)
        lines.append(f"{conf_key} {value}")

    return "\n".join(lines)


#================================
#===========QUICKSHELL============
#================================
def generateQuickshellJson(theme: dict[str, Any]) -> str:
    """Quickshell legge JSON già risolto: nessun riferimento '@' da capire lato QML."""
    payload = {
        "theme_name": theme.get("theme_name"),
        "colors": theme.get("colors", {}),
        "fonts": theme.get("fonts", {}),
        "quickshell": theme.get("quickshell", {}),
    }
    return json.dumps(payload, indent=2, ensure_ascii=False)


#================================
#============FUZZEL===============
#================================
def _stripHash(value: str) -> str:
    return value.lstrip("#")


def generateFuzzelIni(theme: dict[str, Any]) -> str:
    fz = theme.get("fuzzel", {})
    lines = ["# Generato da scripts/applyTheme.py — non modificare a mano", "[main]"]
    if "font_family" in fz:
        font_line = fz["font_family"]
        if "font_size" in fz:
            font_line += f":size={fz['font_size']}"
        lines.append(f"font={font_line}")
    if "icon_theme" in fz:
        lines.append(f"icon-theme={fz['icon_theme']}")

    lines.append("")
    lines.append("[colors]")
    # fuzzel vuole hex a 8 cifre (RRGGBBAA) senza '#'
    color_map = {
        "background": "background",
        "foreground": "text",
        "border_color": "border",
        "selection_color": "selection",
        "selection_text_color": "selection-text",
        "selection_match_color": "selection-match",
        "match_color": "match",
        "placeholder_color": "placeholder",
        "prompt_color": "prompt",
    }
    for toml_key, ini_key in color_map.items():
        if toml_key in fz:
            lines.append(f"{ini_key}={_stripHash(fz[toml_key])}ff")

    lines.append("")
    lines.append("[border]")
    if "border_width" in fz:
        lines.append(f"width={fz['border_width']}")
    if "border_radius" in fz:
        lines.append(f"radius={fz['border_radius']}")

    return "\n".join(lines)


#================================
#=============CAVA===============
#================================
def generateCavaConf(theme: dict[str, Any]) -> str:
    cava = theme.get("cava", {})
    lines = ["# Generato da scripts/applyTheme.py — non modificare a mano", "[color]"]

    if cava.get("gradient_enabled"):
        lines.append("gradient = 1")
        for i in (1, 2, 3):
            key = f"gradient_color_{i}"
            if key in cava:
                lines.append(f"gradient_color_{i} = '{cava[key]}'")
    elif "foreground" in cava:
        lines.append(f"foreground = '{cava['foreground']}'")

    if "background" in cava:
        lines.append(f"background = '{cava['background']}'")

    lines.append("")
    lines.append("[general]")
    for key in ("bars", "bar_width", "bar_spacing"):
        if key in cava:
            lines.append(f"{key.replace('_', '_')} = {cava[key]}")

    return "\n".join(lines)


#================================
#===========FASTFETCH=============
#================================
def generateFastfetchJsonc(theme: dict[str, Any]) -> str:
    """Fastfetch legge la propria config principale a parte; qui produciamo solo
    lo snippet dei colori/palette da includere (fastfetch supporta $include nei
    file jsonc), così non dobbiamo rigenerare l'intera config a ogni cambio tema."""
    ff = theme.get("fastfetch", {})
    kitty_colors = {k: v for k, v in theme.get("kitty", {}).items() if k.startswith("color")}

    payload = {
        "theme_name": theme.get("theme_name"),
        "logo": {
            "color1": ff.get("logo_color_1"),
            "color2": ff.get("logo_color_2"),
            "paddingLeft": ff.get("logo_padding_left"),
        },
        "display": {
            "keyColor": ff.get("key_color"),
            "valueColor": ff.get("value_color"),
            "separator": ff.get("separator"),
            "separatorColor": ff.get("separator_color"),
            "titleColor": ff.get("title_color"),
            "osColor": ff.get("os_color"),
        },
        "colorBlock": {
            "width": ff.get("color_block_width"),
            "rangeStart": ff.get("color_block_range_start"),
            "rangeEnd": ff.get("color_block_range_end"),
        },
        "colors": kitty_colors,
    }
    return json.dumps(payload, indent=2, ensure_ascii=False)


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
    # (fuzzel/cava/fastfetch leggono il file solo al lancio, nessun reload necessario)


#================================
#===========GENERATORI============
#================================
# Ogni riga: (etichetta stampata, file di output, funzione generatrice)
# Aggiungere un nuovo programma nel monorepo = aggiungere una riga qui,
# nient'altro va toccato in main().
GeneratorFn = Callable[[dict[str, Any]], str]
GENERATORS: list[tuple[str, Path, GeneratorFn]] = [
    ("hyprland",  HYPR_OUTPUT,       generateHyprlandLua),
    ("kitty",     KITTY_OUTPUT,      generateKittyConf),
    ("quickshell", QUICKSHELL_OUTPUT, generateQuickshellJson),
    ("fuzzel",    FUZZEL_OUTPUT,     generateFuzzelIni),
    ("cava",      CAVA_OUTPUT,       generateCavaConf),
    ("fastfetch", FASTFETCH_OUTPUT,  generateFastfetchJsonc),
]


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
    raw_theme = loadTheme(theme_path)
    theme = resolveTheme(raw_theme)  # <- unico punto di risoluzione dei riferimenti "@"

    total = len(GENERATORS)
    for i, (label, output_path, generator) in enumerate(GENERATORS, start=1):
        print(f"[{i}/{total}] Generazione {label}")
        writeStateFile(output_path, generator(theme))
        print(f"      scritto in {output_path}")

    print(f"[{total}/{total}] Reload")
    triggerReload()

    print("\nFatto.")


if __name__ == "__main__":
    main()