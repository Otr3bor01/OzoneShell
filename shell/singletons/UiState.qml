pragma Singleton
import QtQuick

QtObject {
    property bool settingsOpen: false
    function toggleSettings() {
        settingsOpen = !settingsOpen
    }

    property bool themeMenuOpen: false
    function toogleThemeMenu() {
        themeMenuOpen = !themeMenuOpen
    }

}