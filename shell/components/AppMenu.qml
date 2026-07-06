import "../primitives"
import QtQuick
HoverCapsule {
    baseWidth: 30
    hoverWidth: 35
    capsuleHeight: 30

    content: Text {
        anchors.centerIn: parent
        text: "󰣇"
        font.pixelSize: 20
        color: Theme.accent
    }
}
