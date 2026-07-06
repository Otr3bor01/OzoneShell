pragma Singleton
import QtQuick
import Quickshell.Io

QtObject {
    id: root

    // Nomi semantici invece di leggere hex sparsi in ogni file:
    // se un domani rinomini una chiave nel JSON, cambi solo qui.
    readonly property string themeName: _data.theme_name ?? "Ozone"
    readonly property color background: Qt.rgba(0.07, 0.05, 0.12, 0.5)
    readonly property color accent: _data.colors?.special?.icons ?? "#C87DD4"
    readonly property color foreground: _data.colors?.special?.foreground ?? "#D9D0E8"
    readonly property color border: "#443355"
    readonly property string fontFamily: _data.font?.family ?? "Iosevka"

    property var _data: ({})

    property FileView themeFile: FileView {
        id: themeFile
        path: "/home/otr3bor/.config/quickshell/state/theme.json"
        watchChanges: true
        onFileChanged: reload()
        onLoaded: {
            try {
                root._data = JSON.parse(text())
            } catch (e) {
                console.warn("Theme.qml: JSON non valido, mantengo i valori precedenti", e)
            }
        }
    }
}
