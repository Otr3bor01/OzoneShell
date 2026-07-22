import QtQuick
import QtQuick.Layouts
import qs.singletons

Item {
    id: root

    property var currentTime: new Date()

    Layout.alignment: Qt.AlignVCenter
    Layout.rightMargin: 100
    Layout.bottomMargin: 0

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: root.currentTime = new Date()
    }

    RowLayout {
        anchors.centerIn: parent
        spacing: 2

        Text { // clock icon
            text: "\uf017"
            color: Theme.icons
            font.pixelSize: 18
            font.bold: true
            font.family: Theme.fontFamilyIcons
        }

        Text { // time
            text: Qt.formatDateTime(root.currentTime, "hh:mm")
            color: Theme.foreground
            font.pixelSize: Theme.fontSizeNormal
            font.bold: true
            font.family: Theme.fontFamily
        }

        Text { // spacer
            text: "      "
        }

        Text { // calendar icon
            text: "\uf073"
            color: Theme.icons
            font.pixelSize: 18
            font.bold: true
            font.family: Theme.fontFamilyIcons
        }

        Text { // date
            text: Qt.formatDateTime(root.currentTime, "dd/MM/yyyy")
            color: Theme.foreground
            font.pixelSize: Theme.fontSizeNormal
            font.bold: true
            font.family: Theme.fontFamily
        }
    }
}