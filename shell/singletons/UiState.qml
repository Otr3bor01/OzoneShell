// singletons/UiState.qml
pragma Singleton
import QtQuick

QtObject {
    property bool settingsOpen: false

    function toggleSettings() {
        settingsOpen = !settingsOpen
    }
}