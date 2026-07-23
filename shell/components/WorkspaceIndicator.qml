import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import qs.singletons
import qs.components

Rectangle {
    id: root
    property int wsMin: 1
    property int wsMax: 5
    property string activeMonitorValue: "false"
    required property string monitorName

    property var monitorObj: Hyprland.monitors.values.find(m => m.name === root.monitorName)
    property var specialWs: monitorObj ? monitorObj.lastIpcObject.specialWorkspace : null
    readonly property bool specialActive: !!specialWs && specialWs.name !== ""

    implicitWidth: wsRow.width

    color: Qt.alpha(Theme.background, Theme.panelOpacity) //Do i want this to be a fixed color? 
    radius: Theme.panelRadius
    border.color: monitorState.text().trim() === root.activeMonitorValue ? Theme.activeBorder : Theme.inactiveBorder
    border.width: Theme.panelBorderWidth

    FileView {
        id: monitorState
        path: "/tmp/hypr_secondMonitor"
        watchChanges: true
        onFileChanged: reload()
    }
    
    Connections {
        target: Hyprland
        function onRawEvent(event) {
            if (event.name === "activespecial") {
                Hyprland.refreshMonitors()
            }
        }
    }

    Row {
        id: wsRow
        anchors.centerIn: parent
        spacing: 6
        padding: 8

        Repeater {
            model: Hyprland.workspaces.values.filter(ws => ws.id > root.wsMin - 1 && ws.id <= root.wsMax)
            delegate: WorkspaceButton {}             
        }
    }
    Rectangle {
        anchors.fill: parent
        color: Qt.alpha(Theme.background, 1)
        radius: Theme.panelRadius
        border.color: monitorState.text().trim() === root.activeMonitorValue ? Theme.activeBorder : Theme.inactiveBorder
        border.width: Theme.panelBorderWidth + 2

        scale: root.specialActive ? 1 : 0
        opacity: root.specialActive ? 1 : 0
        transformOrigin: Item.Center

        Behavior on opacity { NumberAnimation { duration: 120 } }
        Behavior on scale {
            NumberAnimation {
                duration: 120
                easing.type: root.specialActive ? Easing.OutBack : Easing.InBack
                easing.overshoot: 0
            }
        }

        Text {
            id: secretText
            anchors.centerIn: parent
            text: "SECRET"
            font.pixelSize: 20
            font.bold: true
            font.italic: true
            font.letterSpacing: 20
            color: Theme.accent
        }
    }
}