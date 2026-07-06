import QtQuick
import Quickshell.Io
import Quickshell.Hyprland

// Uso (da Bar.qml):
// WorkspaceIndicator {
//     workspaceStart: 1
//     workspaceEnd: 5
//     monitorStateFile: "/tmp/hypr_secondMonitor"
// }
Rectangle {
    id: root

    property int workspaceStart: 1
    property int workspaceEnd: 5
    property string monitorStateFile: "/tmp/hypr_secondMonitor"

    implicitWidth: 290
    implicitHeight: 35
    color: Theme.background
    radius: 100
    border.color: monitorState.text().trim() === "false" ? Theme.foreground : Theme.border
    border.width: 1.5

    FileView {
        id: monitorState
        path: root.monitorStateFile
        watchChanges: true
        onFileChanged: reload()
    }

    Row {
        anchors.fill: parent
        anchors.centerIn: parent
        spacing: 6
        padding: 8

        Repeater {
            model: Hyprland.workspaces.values.filter(
                ws => ws.id >= root.workspaceStart && ws.id <= root.workspaceEnd
            )
            delegate: Rectangle {
                width: 50
                height: 10
                radius: 5
                color: modelData.active ? Theme.accent : Theme.background
                border.color: modelData.active
                    ? Theme.foreground
                    : mouseArea.containsMouse
                        ? Qt.rgba(0.85, 0.82, 0.91, 0.5)
                        : "#2C2C2E"
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
