import Quickshell
import QtQuick
import qs.components
import qs.modules
import qs.singletons

ShellRoot {
    id: root
    settings.watchFiles: true

    Bar {
        targetScreen: Quickshell.screens.find(s => s.name === Settings.primaryMonitor)
        wsMin: 1
        wsMax: 5
        activeMonitorValue: "false"
    }

    Bar {
        targetScreen: Quickshell.screens.find(s => s.name === Settings.secondaryMonitor)
        wsMin: 6
        wsMax: 10
        activeMonitorValue: "true"
    }
}
