import QtQuick
import QtQuick.Layouts
import qs.singletons

Rectangle {
    implicitWidth: 1000
    implicitHeight: 35
    color: Theme.background
    radius: 100
    border.color: Theme.border
    border.width: 1.5

    RowLayout {
        anchors.fill: parent
        anchors.centerIn: parent
        spacing: 30

        Item {
            Layout.alignment: Qt.AlignVCenter
            Layout.leftMargin: 60
            ThemeLabel { anchors.centerIn: parent }
        }

        Item {
            implicitWidth: 300
            Layout.rightMargin: 200
            Layout.leftMargin: 200
            Layout.alignment: Qt.AlignHCenter
            MediaWidget { anchors.fill: parent }
        }

        Item {
            Layout.alignment: Qt.AlignVCenter
            Layout.rightMargin: 100
            Clock { anchors.centerIn: parent }
        }
    }
}
