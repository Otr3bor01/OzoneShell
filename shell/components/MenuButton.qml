import QtQuick 
import Quickshell
import qs.components
import qs.singletons

Item{   //menù work in progress
    id: root
    width: 35
    height: width
    Rectangle {
        id: archMenu
        implicitWidth: parent.width - 5
        implicitHeight: implicitWidth
        radius: implicitWidth / 2
        anchors.centerIn: parent

        color: Qt.alpha(Theme.background, Theme.panelOpacity)
        border.color: Theme.inactiveBorder
        border.width: Theme.panelBorderWidth

        Behavior on implicitWidth {
            NumberAnimation {
                duration: 150
                easing.type: Easing.OutCubic
            }
        }

        MouseArea {
            id: archMenuMouse
            anchors.fill: parent
            hoverEnabled: true
            onClicked: UiState.settingsOpen = !UiState.settingsOpen
        }

        states: [
            State {
                name: "hovered"
                when: archMenuMouse.containsMouse
                PropertyChanges {
                    target: archMenu
                    implicitWidth: root.width +5
                    border.color: Theme.activeBorder
                    border.width: Theme.panelBorderWidth + 0.5
                }
            },

            State {
                name: "default"
                when: !archMenuMouse.containsMouse
                PropertyChanges {
                    target: archMenu
                    implicitWidth: root.width
                    border.color: Theme.inactiveBorder
                    border.width: Theme.panelBorderWidth
                }
            }
        ]
    }
    Text {
        anchors.centerIn: archMenu
        text: "󰣇"
        font.pixelSize : 20
        color: Theme.icons
    }
}