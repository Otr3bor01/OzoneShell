import Quickshell
import QtQuick

// Uso (da shell.qml):
// Bar {
//     screen: modelData
//     workspaceStart: 1
//     workspaceEnd: 5
//     monitorStateFile: "/tmp/hypr_secondMonitor"
// }
PanelWindow {
    id: root
    
    property int workspaceStart: 1
    property int workspaceEnd: 5
    property string monitorStateFile: "/tmp/hypr_secondMonitor"

    aboveWindows: false
    anchors { bottom: false; left: true; top: true; right: true }
    margins { left: 10; top: 10; right: 10 }
    implicitHeight: 35
    color: "transparent"

    Row {
        anchors.fill: parent
        spacing: 5

        WorkspaceIndicator {
            workspaceStart: root.workspaceStart
            workspaceEnd: root.workspaceEnd
            monitorStateFile: root.monitorStateFile
        }

        Rectangle { width: 150; height: 100; color: "transparent" } // spacer

        CentralBar { }

        Rectangle { width: 250; height: 100; color: "transparent" } // spacer

        Item {
            width: 35; height: 35
            anchors.verticalCenter: parent.verticalCenter
            AppMenu { anchors.centerIn: parent }
        }

        VolumeWidget { anchors.verticalCenter: parent.verticalCenter }

        UpdatesWidget { anchors.verticalCenter: parent.verticalCenter }
    }
}
