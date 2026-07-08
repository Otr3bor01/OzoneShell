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
        color: Qt.alpha(Theme.background, Theme.panelOpacity)
        radius: 12
        border.color: Theme.border
        border.width: Theme.panelBorderWidth * 3
        //blah blah blah gui
        Item {
            anchors.verticalCenter: parent.verticalCenter
            transform: Rotation {origin.x: 25; origin.y: 25; angle: 45}
            Text {
                text: "Blah Blah WIP"
                color: Theme.accent
                font.family: Theme.fontFamily
                font.pixelSize: 50
                font.bold: true
            }
        }
    }
}