import QtQuick 
import Quickshell
import qs.components
import qs.singletons

Item{  
    id: root
    width: 35
    height: width
    Rectangle {
        id: exit
        implicitWidth: parent.width
        implicitHeight: implicitWidth
        radius: implicitWidth / 2
        anchors.centerIn: parent

        color: Qt.alpha("#000000", 0)
        border.color: Qt.alpha("#000000", 0)



        MouseArea {
            id: exitMouse
            anchors.fill: parent
            hoverEnabled: true
            onClicked: UiState.settingsOpen = false
        }
        
        states: [
            State {
                name: "hovered"
                when: exitMouse.containsMouse
                PropertyChanges {
                    target: testo
                    font.pixelSize: 30
                    color: Theme.icons
                }
            },

            State {
                name: "default"
                when: !exitMouse.containsMouse
                PropertyChanges {
                    target: testo
                    font.pixelSize: 20
                    color: Qt.alpha(Theme.icons, 0.5)
                }
            }
        ]
    }
    Text {
        id: testo
        anchors.centerIn: exit
        text: "\u{f015a}"
        font.pixelSize : 20
        color: Qt.alpha(Theme.icons, 0.5)
        Behavior on font.pixelSize {
            NumberAnimation {
                duration: 100
                easing.type: Easing.OutCubic
            }
       }
    }
}