import QtQuick

// Uso:
// HoverCapsule {
//     baseWidth: 60
//     hoverWidth: 65
//     capsuleHeight: 30
//     onClicked: doSomething()
//     content: Text { text: "..." }
// }
Item {
    id: root

    property int baseWidth: 60
    property int hoverWidth: baseWidth + 5
    property int capsuleHeight: 30
    property color accentColor: Theme.accent
    property color idleBorderColor: Theme.border
    property int animationDuration: 150
    // true quando qualcos'altro (es. un'animazione di volume) vuole forzare
    // la larghezza "compressa" anche in hover — copre il caso vol.inPulse/inPulse2
    property bool forceCompact: false

    default property alias content: contentItem.children
    readonly property alias hovered: mouseArea.containsMouse

    signal clicked(var mouse)
    signal wheel(var event)

    implicitWidth: capsule.implicitWidth
    implicitHeight: capsuleHeight

    Rectangle {
        id: capsule
        implicitWidth: root.baseWidth
        implicitHeight: root.capsuleHeight
        radius: implicitHeight / 2
        anchors.centerIn: parent
        color: Theme.background
        border.color: root.idleBorderColor
        border.width: 1.5

        Behavior on implicitWidth {
            NumberAnimation { duration: root.animationDuration; easing.type: Easing.OutCubic }
        }

        Item {
            id: contentItem
            anchors.centerIn: parent
        }

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: (mouse) => root.clicked(mouse)
            onWheel: (event) => root.wheel(event)
        }

        states: [
            State {
                name: "hovered"
                when: mouseArea.containsMouse && !root.forceCompact
                PropertyChanges {
                    target: capsule
                    implicitWidth: root.hoverWidth
                    border.color: root.accentColor
                    border.width: 2
                }
            },
            State {
                name: "default"
                when: !mouseArea.containsMouse || root.forceCompact
                PropertyChanges {
                    target: capsule
                    implicitWidth: root.baseWidth
                    border.color: root.idleBorderColor
                    border.width: 1.5
                }
            }
        ]
    }
}
