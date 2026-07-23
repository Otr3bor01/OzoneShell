import QtQuick
import Quickshell.Hyprland
import qs.singletons

Rectangle {
    id: root
    required property var modelData // modelData from the Repeater

    width: 50
    height: 10
    radius: 5
    transformOrigin: Item.center

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

    SequentialAnimation {
        id: bounce
        NumberAnimation {
            target: root
            property: "scale"
            to: 1.25
            duration: 100
            easing.type: Easing.OutQuad
        }
        NumberAnimation {
            target: root
            property: "scale"
            to: 1
            duration: 180
            easing.type: Easing.OutBack
            easing.overshoot: 3
        }
    }

    Connections {
        target: modelData
        function onActiveChanged() {
            if (modelData.active) bounce.start()
        }
    }


    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: Hyprland.dispatch("hl.dsp.focus({ workspace = " + modelData.id + " })")
    }
}