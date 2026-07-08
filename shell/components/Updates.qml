import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.singletons

Item {
    id: updates

    property int baseWidth: 65
    property int hoverWidth: 70

    property int updateCount: 0

    width: hoverWidth
    height: baseWidth - 30

    Timer {
        interval: 600000
        repeat: true
        running: true
        triggeredOnStart: true
        onTriggered: updatesCheck.running = true
    }

    Timer {
        id: refreshTimer
        interval: 30000
        repeat: true
        running: false
        property int ticks: 0
        onTriggered: {
            updatesCheck.running = true
            ticks++
            if (ticks >= 20) { 
                stop()
                ticks = 0
            }
        }
        onRunningChanged: {
            if (running) ticks = 0
        }
    }

    Process {
        id: updatesCheck
        command: ["checkupdates"]
        stdout: SplitParser {
            onRead: (line) => {
                if (line.trim() !== "")
                    updates.updateCount++
            }
        }
        onRunningChanged: {
            if (running) updates.updateCount = 0
        }
    }

    Process {
        id: updateRun
        command: ["kitty", "-e", "bash", "-c", "sudo pacman -Syu; echo '\nPremi invio per chiudere...'; read"]
    }

    Rectangle {
        id: archUpdates
        implicitWidth: updates.baseWidth
        implicitHeight: implicitWidth - 30
        radius: implicitWidth / 2
        anchors.centerIn: parent

        color: Qt.alpha(Theme.background, Theme.panelOpacity)
        border.width: Theme.panelBorderWidth
        border.color: Theme.inactiveBorder

        Behavior on implicitWidth {
            NumberAnimation { duration: 150; easing.type: Easing.OutCubic }
        }

        MouseArea {
            id: archUpdatesMouse
            anchors.fill: parent
            hoverEnabled: true
            onClicked: {
                updateRun.running = true
                refreshTimer.start()
            }
            cursorShape: Qt.PointingHandCursor
        }

        states: [
            State {
                name: "hovered"
                when: archUpdatesMouse.containsMouse
                PropertyChanges {
                    target: archUpdates
                    implicitWidth: updates.hoverWidth
                    border.color: Theme.activeBorder
                    border.width: Theme.panelBorderWidth + 0.5
                }
            },
            State {
                name: "default"
                when: !archUpdatesMouse.containsMouse
                PropertyChanges {
                    target: archUpdates
                    implicitWidth: updates.baseWidth
                    border.color: Theme.inactiveBorder
                    border.width: Theme.panelBorderWidth
                }
            }
        ]

        RowLayout {
            anchors.centerIn: parent
            spacing: 4

            Text {
                text: "󰚰"
                font.pixelSize: Theme.fontSizeNormal
                font.family: Theme.fontFamilyIcons
                color: Theme.icons
                Layout.alignment: Qt.AlignVCenter
            }
            Text {
                text: updates.updateCount > 0 ? updates.updateCount : "0"
                color: updates.updateCount > 0 ? Theme.foreground : Theme.icons
                font.pixelSize: Theme.fontSizeNormal
                font.family: Theme.fontFamily
                Layout.alignment: Qt.AlignVCenter
            }
        }
    }
}