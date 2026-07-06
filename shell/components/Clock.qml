import QtQuick
import QtQuick.Layouts

Item {
    id: root
    property var currentTime: new Date()

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: root.currentTime = new Date()
    }

    RowLayout {
        anchors.centerIn: parent
        spacing: 2

        Text {
            text: ""
            color: Theme.accent
            font.pixelSize: 18
            font.bold: true
        }
        Text {
            text: Qt.formatDateTime(root.currentTime, "hh:mm")
            color: Theme.foreground
            font.pixelSize: 16
            font.bold: true
            font.family: Theme.fontFamily
        }
        Text { text: "      " }
        Text {
            text: ""
            color: Theme.accent
            font.pixelSize: 18
            font.bold: true
        }
        Text {
            text: Qt.formatDateTime(root.currentTime, "dd/MM/yyyy")
            color: Theme.foreground
            font.pixelSize: 16
            font.bold: true
            font.family: Theme.fontFamily
        }
    }
}
