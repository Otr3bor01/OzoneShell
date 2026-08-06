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
        id: nightLightRect
        implicitWidth: parent.width - 5
        implicitHeight: implicitWidth
        radius: implicitWidth / 2
        anchors.centerIn: parent

        color: NightLightState.active ? Qt.alpha(Theme.icons, Theme.panelOpacity) : Qt.alpha(Theme.background, Theme.panelOpacity)
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
            onClicked: NightLightState.toggle()
        }

        states: [
            State {
                name: "hovered"
                when: rebootMouse.containsMouse
                PropertyChanges {
                    target: nightLightRect
                    implicitWidth: root.width +5
                    border.color: Theme.activeBorder
                    border.width: Theme.panelBorderWidth + 0.5
                }
            },

            State {
                name: "default"
                when: !rebootMouse.containsMouse
                PropertyChanges {
                    target: nightLightRect
                    implicitWidth: root.width
                    border.color: Theme.inactiveBorder
                    border.width: Theme.panelBorderWidth
                }
            }
        ]
    }
    Text {
        anchors.centerIn: nightLightRect
        text: "\u{f1a4c}"
        font.pixelSize : 20
        color: NightLightState.active ? Theme.normalBlack :Theme.icons
    }
}