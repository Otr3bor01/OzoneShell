import QtQuick
import Quickshell
import qs.components

PanelWindow {
    id: root
    property var targetScreen
    property int wsMin: 1
    property int wsMax: 5
    property string activeMonitorValue: "false"

    exclusiveZone: 20
    screen: targetScreen
    aboveWindows: false
    implicitHeight: 40
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
        anchors {
            left: parent.left
            top: parent.top
            bottom: parent.bottom
            margins: 5
        }


        id: wsIndicator
        wsMin: root.wsMin
        wsMax: root.wsMax
        activeMonitorValue: root.activeMonitorValue
    }
    
}