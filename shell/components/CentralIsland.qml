import QtQuick
import Quickshell
import qs.singletons
import qs.components

Rectangle {
    id: root
    implicitWidth: 1100
    color: Qt.alpha(Theme.background, Theme.panelOpacity)
    radius: 100
    border.color: Theme.border
    border.width: Theme.panelBorderWidth

    ThemeDisplay {
        id: themeDisplay
        anchors.left: parent.left
        anchors.leftMargin: 10
        anchors.verticalCenter: parent.verticalCenter
    }

    BarMediaPlayer {
        id: barMediaPlayer
        anchors {   
            top: parent.top
            horizontalCenter: parent.horizontalCenter
            bottom: parent.bottom
            margins: 5
        }
    }
    
    DateTime {
        id: dateTime
        anchors {
            right: parent.right
            top: parent.top
            bottom: parent.bottom
            margins: 100
        }
    }
}