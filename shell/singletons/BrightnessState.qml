pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    // Mappa nome-monitor Hyprland -> indice display ddcutil
    // Verifica/aggiorna con `ddcutil detect` (campo model/serial per ogni display)
    readonly property var monitorMap: ({
        "DP-1": 1,
        "DP-2": 2
    })

    property int brightnessDP1: 50
    property int brightnessDP2: 50

    function refresh() {
        getProc1.running = true
        getProc2.running = true
    }

    function setDP1(value) {
        brightnessDP1 = value
        debounceDP1.value = value
        debounceDP1.restart()
    }
    function setDP2(value) {
        brightnessDP2 = value
        debounceDP2.value = value
        debounceDP2.restart()
    }

    function setByMonitor(monitorName, value) {
        const displayNum = monitorMap[monitorName]
        if (displayNum === undefined) {
            console.warn("BrightnessState: monitor sconosciuto:", monitorName)
            return
        }
        if (displayNum === 1) setDP1(value)
        else setDP2(value)
    }

    function stepByMonitor(monitorName, delta) {
        const displayNum = monitorMap[monitorName]
        if (displayNum === undefined) {
            console.warn("BrightnessState: monitor sconosciuto:", monitorName)
            return
        }
        const current = displayNum === 1 ? brightnessDP1 : brightnessDP2
        const v = Math.max(0, Math.min(100, current + delta))
        setByMonitor(monitorName, v)
    }

    Timer {
        id: debounceDP1
        interval: 150
        property int value: 50
        onTriggered: {
            setProc1.command = ["ddcutil", "--display", "1", "setvcp", "10", String(value)]
            setProc1.running = true
        }
    }
    Timer {
        id: debounceDP2
        interval: 150
        property int value: 50
        onTriggered: {
            setProc2.command = ["ddcutil", "--display", "2", "setvcp", "10", String(value)]
            setProc2.running = true
        }
    }

    Process { id: setProc1 }
    Process { id: setProc2 }

    Process {
        id: getProc1
        command: ["bash", "-c", "ddcutil --display 1 getvcp 10 --brief"]
        stdout: StdioCollector {
            onStreamFinished: {
                const parts = text.trim().split(" ")
                const val = parseInt(parts[3])
                if (!isNaN(val)) root.brightnessDP1 = val
            }
        }
    }
    Process {
        id: getProc2
        command: ["bash", "-c", "ddcutil --display 2 getvcp 10 --brief"]
        stdout: StdioCollector {
            onStreamFinished: {
                const parts = text.trim().split(" ")
                const val = parseInt(parts[3])
                if (!isNaN(val)) root.brightnessDP2 = val
            }
        }
    }

    IpcHandler {
        target: "brightness"
        function up(monitor: string) { root.stepByMonitor(monitor, 5) }
        function down(monitor: string) { root.stepByMonitor(monitor, -5) }
        function set(monitor: string, value: string) { root.setByMonitor(monitor, parseInt(value)) }
    }

    Component.onCompleted: refresh()
}