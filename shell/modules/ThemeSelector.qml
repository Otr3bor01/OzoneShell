//8 Themes, 1 for every color of kitty
//Theme selector and wallpaper folder containing wallpapers coherent to the theme
//Addition of the "Auto" theme and the "Special" wallpapers (If in the settings "Auto" is enabled the themes wheel will become a simple wallpaper selector)
//Called by a bind
import qs.singletons
import QtQuick
import Quickshell
import qs.components

PanelWindow {
    readonly property int dimensiozza: 1100
    anchors { } //floating in the middle
    implicitWidth: dimensiozza
    implicitHeight: dimensiozza
    color: "transparent"
    ThemeOrangeMenu {}
}