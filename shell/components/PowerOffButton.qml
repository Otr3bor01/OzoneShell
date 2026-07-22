import QtQuick 
import Quickshell
import QtQuick.Controls
import qs.components
import qs.singletons


Item{  
    id: root
    width: 35
    height: width
    Rectangle {
        id: powerOffRect
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
            id: powerOffMouse
            anchors.fill: parent
            hoverEnabled: true
            onClicked: Quickshell.execDetached(["systemctl", "poweroff"])
        }

        states: [
            State {
                name: "hovered"
                when: powerOffMouse.containsMouse
                PropertyChanges {
                    target: powerOffRect
                    implicitWidth: root.width +5
                    border.color: Theme.activeBorder
                    border.width: Theme.panelBorderWidth + 0.5
                }
            },

            State {
                name: "default"
                when: !powerOffMouse.containsMouse
                PropertyChanges {
                    target: powerOffRect
                    implicitWidth: root.width
                    border.color: Theme.inactiveBorder
                    border.width: Theme.panelBorderWidth
                }
            }
        ]
    }
    Text {
        anchors.centerIn: powerOffRect
        text: "\uf011"
        font.pixelSize : 20
        color: Theme.icons
    }
}