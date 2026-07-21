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
        id: rebootRect
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
            id: rebootMouse
            anchors.fill: parent
            hoverEnabled: true
            onClicked: Quickshell.execDetached(["systemctl", "reboot"])
        }

        states: [
            State {
                name: "hovered"
                when: rebootMouse.containsMouse
                PropertyChanges {
                    target: rebootRect
                    implicitWidth: root.width +5
                    border.color: Theme.activeBorder
                    border.width: Theme.panelBorderWidth + 0.5
                }
            },

            State {
                name: "default"
                when: !rebootMouse.containsMouse
                PropertyChanges {
                    target: rebootRect
                    implicitWidth: root.width
                    border.color: Theme.inactiveBorder
                    border.width: Theme.panelBorderWidth
                }
            }
        ]
    }
    Text {
        anchors.centerIn: rebootRect
        text: "󰜉"
        font.pixelSize : 20
        color: Theme.icons
    }
}