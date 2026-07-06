from pathlib import Path
import tomllib
#1: detect activation when the new theme is chosen (triggered probably from quickshell or hyprland. We will call these programs "Selectors")
#2: read the current_theme file (generated from the selector)
#3: find the theme.toml
#4: read the theme.toml parameters
#5: generate a coherent config file for every program (quickshell, hyprland, cava, kitty, thunar, ecc)
#6: place this file as a placeholder as "activeTheme"

#================================
#======READ CURRENT_THEME========
#================================

def readCurrentTheme():
    current_theme_path =  Path("~/.config/ozone/themes/current_theme").expanduser()
    with open(current_theme_path) as f:
        current_theme = f.read()
    return current_theme

#================================
#=========FIND THEME.TOML========
#================================

def findCurrentTheme(current_theme):
    theme_path = Path(f"~/.config/ozone/themes/{current_theme}/{current_theme}.toml").expanduser()
    return theme_path

#================================
#===========INIT SCRIPT==========
#================================
def importTOML(theme_path):
    with open(theme_path, "rb") as f:
        theme = tomllib.load(f)
    return theme

#================================
#============HYPRLAND============
#================================
print(importTOML(findCurrentTheme(readCurrentTheme()))) #debug