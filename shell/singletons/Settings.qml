//Currently manually made. In the future, this should be generated from the installation and edited from the setting gui.

pragma Singleton
import QtQuick
import Quickshell.Io

QtObject {
    id: root

    property string workspaceMode: "revolver"
    property string audioFeedback: "none"
    property bool batteryWidgetEnabled: true
    property string primaryMonitor: "DP-1"
    property string secondaryMonitor: "DP-2"

    property var _data: ({})

    function reload() {
        try {
            root._data = JSON.parse(settingsFile.text())
            updateProperties()
            console.log("Settings reloaded:", JSON.stringify(root._data))
        } catch (e) {
            console.warn("Settings.qml: Errore nel reload", e)
        }
    }

    function updateProperties() {
        workspaceMode = _data.workspaceMode ?? "revolver"
        audioFeedback = _data.audioFeedback ?? "none"
        batteryWidgetEnabled = _data.batteryWidgetEnabled ?? true
        primaryMonitor = _data.primaryMonitor ?? "DP-1"
        secondaryMonitor = _data.secondaryMonitor ?? "DP-2"
    }

    property FileView settingsFile: FileView {
        id: settingsFile
        path: "/home/otr3bor/.config/quickshell/state/settings.json"
        watchChanges: true
        onFileChanged: reload()
        onLoaded: {
            try {
                root._data = JSON.parse(text())
                updateProperties()
                console.log("Settings loaded:", JSON.stringify(root._data))
            } catch (e) {
                console.warn("Settings.qml: JSON non valido, mantengo i valori precedenti", e)
            }
        }
    }
}
