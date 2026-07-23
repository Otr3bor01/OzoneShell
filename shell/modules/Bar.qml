import QtQuick
import Quickshell
import qs.components

PanelWindow {
    id: root
    property var targetScreen
    property int wsMin: 1
    property int wsMax: 5
    property string activeMonitorValue: "false"
    color: "transparent"
    exclusiveZone: 35
    screen: targetScreen
    aboveWindows: false
    implicitHeight: 50
    margins {
        top: 5
        left: 10
        right: 10
    }
    anchors{
        bottom: false;
        left: true;
        top: true;
        right: true;   
    }

    WorkspaceIndicator {
        id: wsIndicator
        wsMin: root.wsMin
        wsMax: root.wsMax
        activeMonitorValue: root.activeMonitorValue
        monitorName: root.targetScreen.name
        anchors {
            left: parent.left
            top: parent.top
            bottom: parent.bottom
            margins: 5
        }
    }
    
    CentralIsland {
        id: centralIsland
        anchors {
            horizontalCenter: parent.horizontalCenter
            top: parent.top
            bottom: parent.bottom
            margins: 5
        }
    }

    RightButtonsRow {
        id: rightButtonsRow
        anchors {
            right: parent.right
            top: parent.top
            bottom: parent.bottom
            margins: 5
        }
    }
    

}