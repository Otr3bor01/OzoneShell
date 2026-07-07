//Currently manually made. In the future, this should be generated from the installation and edited from the setting gui.

pragma Singleton
import QtQuick
import Quickshell.Io

QtObject {
    id: root

    readonly property string workspaceMode: _data.workspaceMode ?? "revolver"
    readonly property string audioFeedback: _data.audioFeedback ?? "none"
    readonly property bool batteryWidgetEnabled: _data.batteryWidgetEnabled ?? true
    readonly property string primaryMonitor: _data.primaryMonitor ?? "DP-1"
    readonly property string secondaryMonitor: _data.secondaryMonitor ?? "DP-2"

    property var _data: ({})

    property FileView settingsFile: FileView {
        id: settingsFile
        path: "/home/otr3bor/.config/quickshell/state/settings.json"
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
