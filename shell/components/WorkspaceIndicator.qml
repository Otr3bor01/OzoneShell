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
    property bool secret: false

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
    //Rectangle { //Still not working :*)
    //    property var specialWs: Hyprland.workspaces.values.find(w => w.name === "special:secret")
    //    property bool specialActive: !!(specialWs && specialWs.active)
    //    anchors.fill: parent
    //    radius: Theme.panelRadius
    //    color: specialActive ? Theme.background : Qt.alpha("#000000", 0.0)
    //    border.color: Theme.activeBorder
    //    border.width: Theme.panelBorderWidth + 2
    //}
}