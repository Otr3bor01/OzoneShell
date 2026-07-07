import QtQuick
import Quickshell.Hyprland
import qs.singletons

Rectangle {
    id: root
    required property var modelData // modelData from the Repeater

    width: 50
    height: 10
    radius: 5

    color: modelData.active
        ? Qt.alpha(Theme.accent, Theme.panelOpacity)
        : Qt.alpha(Theme.background, Theme.panelOpacity)
    border.color: modelData.active
        ? Theme.activeBorder
        : mouseArea.containsMouse
            ? Qt.alpha(Theme.activeBorder, Theme.panelOpacity)
            : Theme.inactiveBorder
    border.width: 2
    anchors.verticalCenter: parent.verticalCenter

    // Some basic animations
    Behavior on color { ColorAnimation { duration: 150 } }
    Behavior on border.color { ColorAnimation { duration: 150 } }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: Hyprland.dispatch("hl.dsp.focus({ workspace = " + modelData.id + " })")
    }
}