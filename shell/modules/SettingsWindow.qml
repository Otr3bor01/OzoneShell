import qs.singletons
import QtQuick
import Quickshell
import qs.components
PanelWindow {
    anchors { } //floating
    implicitWidth: 400
    implicitHeight: 500
    color: "transparent"

    Rectangle {
        anchors.centerIn: parent
        width: parent.width
        height: parent.height
        color: Theme.background
        radius: 12
        //blah blah blah gui
    }
}