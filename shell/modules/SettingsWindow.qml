import qs.singletons
import QtQuick
import Quickshell
import QtQuick.Layouts
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
        color: Qt.alpha(Theme.background, Theme.panelOpacity)
        radius: 12
        border.color: Theme.border
        border.width: Theme.panelBorderWidth * 3
        //blah blah blah gui
        ColumnLayout {
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            anchors.leftMargin: 5
            PowerOffButton{}
            RebootButton{}
        }
    }
}