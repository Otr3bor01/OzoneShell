pragma Singleton
import QtQuick
import QtCore
import Quickshell

Singleton {
    readonly property string configDir: StandardPaths.writableLocation(StandardPaths.ConfigLocation) + "/quickshell"
    readonly property string stateDir: configDir + "/state"
    readonly property string themeFile: stateDir + "/theme.json"
    readonly property string themeIndexFile: stateDir + "/themeIndex.json"
}