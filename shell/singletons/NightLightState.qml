//currently AI made
pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property bool active: false
    readonly property int filteredTemp: 3500

    function toggle() {
        checkDaemonProc.pendingState = !active
        checkDaemonProc.running = true
    }

    // 1. Verifica se hyprsunset gira
    Process {
        id: checkDaemonProc
        property bool pendingState: false
        command: ["pgrep", "-x", "hyprsunset"]
        onExited: (exitCode) => {
            if (exitCode !== 0) {
                // demone non in esecuzione: avvialo, poi applica dopo un breve delay
                startDaemonProc.running = true
                applyDelay.pendingState = pendingState
                applyDelay.start()
            } else {
                applyState(pendingState)
            }
        }
    }

    // 2. Avvia il demone se non c'è (detached, resta vivo dopo)
    Process {
        id: startDaemonProc
        command: ["hyprsunset"]
    }

    // 3. Piccolo delay per dare tempo al demone di creare il socket
    Timer {
        id: applyDelay
        interval: 400
        property bool pendingState: false
        onTriggered: applyState(pendingState)
    }

    function applyState(newState) {
        applyProc.pendingState = newState
        applyProc.command = newState
            ? ["hyprctl", "hyprsunset", "temperature", String(filteredTemp)]
            : ["hyprctl", "hyprsunset", "identity"]
        applyProc.running = true
    }

    // 4. Applica lo stato, aggiorna `active` solo se il comando riesce davvero
    Process {
        id: applyProc
        property bool pendingState: false
        onExited: (exitCode) => {
            if (exitCode === 0) {
                root.active = pendingState
            } else {
                console.warn("NightLightState: hyprctl fallito, exit code:", exitCode)
            }
        }
    }
}