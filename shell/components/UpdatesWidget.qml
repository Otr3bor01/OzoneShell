import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import "../primitives"

Item {
    id: root
    property int updateCount: 0
    width: 65
    height: 35

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
            if (ticks >= 20) { stop(); ticks = 0 }
        }
        onRunningChanged: if (running) ticks = 0
    }
    Process {
        id: updatesCheck
        command: ["checkupdates"]
        stdout: SplitParser {
            onRead: (line) => { if (line.trim() !== "") root.updateCount++ }
        }
        onRunningChanged: if (running) root.updateCount = 0
    }
    Process {
        id: updateRun
        command: ["kitty", "-e", "bash", "-c", "sudo pacman -Syu; echo '\nPremi invio per chiudere...'; read"]
    }

    HoverCapsule {
        anchors.centerIn: parent
        baseWidth: 60
        hoverWidth: 65
        capsuleHeight: 30
        onClicked: {
            updateRun.running = true
            refreshTimer.start()
        }

        content: RowLayout {
            spacing: 4
            Text {
                text: "󰚰"
                font.pixelSize: 16
                color: Theme.accent
            }
            Text {
                text: root.updateCount > 0 ? root.updateCount : "0"
                color: root.updateCount > 0 ? Theme.foreground : Theme.accent
                font.pixelSize: 16
                font.family: Theme.fontFamily
            }
        }
    }
}
