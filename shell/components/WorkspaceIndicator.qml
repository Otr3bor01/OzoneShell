import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import qs.singletons

Rectangle {
    id: root
    implicitWidth: 290
    implicitHeight: 35
    color: Qt.rgba(18/255, 13/255, 30/255, 0.5)
    radius: 100
    border.color: monitorState.text().trim() === "false" ? Theme.activeBorder : Theme.inactiveBorder
    border.width: 1.5

    FileView {
        id: monitorState
        path: "/tmp/hypr_secondMonitor"
        watchChanges: true
        onFileChanged: reload()
    }

    Row {
        anchors.fill: parent
        anchors.centerIn: parent
        spacing: 6
        padding: 8
        Repeater {
            model: Hyprland.workspaces.values.filter(ws => ws.id > 0 && ws.id <= 5)
            delegate: Rectangle {
                width: 50
                height: 10
                radius: 5
                color: modelData.active ? Theme.accent : Qt.rgba(18/255, 13/255, 30/255, 0.5)
                border.color: modelData.active
                    ? Theme.foreground
                    : mouseArea.containsMouse ? Qt.rgba(0.85, 0.82, 0.91, 0.5) : "#2C2C2E"
                border.width: 2
                anchors.verticalCenter: parent.verticalCenter
                MouseArea {
                    id: mouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Hyprland.dispatch("hl.dsp.focus({ workspace = " + modelData.id + " })")
                }
            }
        }
    }
}