pragma Singleton
import QtQuick
import Quickshell.Io

QtObject {
    id: root

    readonly property string workspaceMode: _data.workspaceMode ?? "revolver"
    readonly property string audioFeedback: _data.audioFeedback ?? "none"
    readonly property bool batteryWidgetEnabled: _data.batteryWidgetEnabled ?? true

    property var _data: ({})

    property FileView settingsFile: FileView {
        id: settingsFile
        path: "/home/otr3bor/.config/quickshell/ozone/state/settings.json"
        watchChanges: true
        onFileChanged: reload()
        onLoaded: {
            try {
                root._data = JSON.parse(text())
            } catch (e) {
                console.warn("Settings.qml: JSON non valido, mantengo i valori precedenti", e)
            }
        }
    }
}
