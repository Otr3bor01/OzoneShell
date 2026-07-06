import Quickshell
import QtQuick
import QtQuick.Layouts
import Quickshell.Hyprland
import Quickshell.Io


PanelWindow {
    screen: Quickshell.screens.find(s => s.name === "DP-2")
    exclusiveZone: 35
    anchors {
        bottom: false;
        left: true;
        top: true;
        right: true;
    }
    
    implicitWidth: 300
    implicitHeight: 35
    color: "transparent"

    margins{
        left: 10;
        top: 10;
        right: 1620;
    }

    FileView {
        id: monitorState
        path: "/tmp/hypr_secondMonitor"
        watchChanges: true
        onFileChanged: reload()
}

    //Hyprland workspace (Am I doing everything wrong?)
    Rectangle { 
        anchors.fill: parent
        color: Qt.rgba(18/255, 13/255, 30/255, 0.5)
        radius: 100
        border.color: monitorState.text().trim() === "true" ? "#D9D0E8" : "#443355"
        border.width: 1.5
        Row {
            anchors.fill: parent
            anchors.centerIn: parent
            spacing: 6
            padding: 8
            Repeater {
                model: Hyprland.workspaces.values.filter(ws => ws.id > 5 && ws.id <= 10)
                delegate: Rectangle {
                    width: 50
                    height: 10
                    radius: 5
                    color: modelData.active 
                        ? "#C87DD4" 
                        : Qt.rgba(18/255, 13/255, 30/255, 0.5)
                    border.color: modelData.active 
                        ? "#D9D0E8" 
                        : mouseArea.containsMouse 
                            ? Qt.rgba(0.85, 0.82, 0.91, 0.5)
                            : "#2C2C2E"
                    border.width: 2
                    anchors.verticalCenter: parent.verticalCenter
                    //on click change workspace
                    MouseArea {
                        id: mouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor

                        onClicked: {
                            Hyprland.dispatch("hl.dsp.focus({ workspace = " + modelData.id + " })")
                        }
                    }
                }
            }
        }
    }
}