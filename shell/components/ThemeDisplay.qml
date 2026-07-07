import QtQuick
import Quickshell
import qs.singletons
import qs.components

Item {
    id: root
    implicitWidth: row.implicitWidth
    implicitHeight: row.implicitHeight
    Row {
        id: row
        anchors.centerIn: parent
        spacing: 1
        Text {
            color: Theme.accent
            font.pixelSize: 18
            font.bold: true
            text: Theme.themeSymbol
            font.family: Theme.fontFamily
        }
        Text {
            id: themeNameText
            text: Theme.themeName
            color: Theme.foreground
            font.pixelSize: 18
            font.bold: true
            font.family: Theme.fontFamily
        }
        Text {
            color: Theme.accent
            font.pixelSize: 18
            font.bold: true
            text: Theme.themeSymbol
            font.family: Theme.fontFamily
        }
    }
}