import qs.singletons
import QtQuick
import Quickshell
import QtQuick.Layouts
import QtQuick.Controls
import qs.components
import Quickshell.Io

PanelWindow {
    anchors { } //floating
    implicitWidth: 400
    implicitHeight: 500
    color: "transparent"

    readonly property var audioFeedbackOptions: ["none", "pop", "megalovania"]
    property var settingsData: ({})

    property FileView settingsFile: FileView {
        id: settingsFile
        path: Paths.repoRoot + "/state/settings.json"
        watchChanges: true
        onLoaded: {
            try {
                settingsData = JSON.parse(text())
                console.log("SettingsWindow: loaded settings", JSON.stringify(settingsData))
            } catch (e) {
                console.warn("SettingsWindow: JSON non valido", e)
                settingsData = ({})
            }
        }
        onFileChanged: {
            console.log("SettingsWindow: file changed, reloading")
            reload()
        }
    }

    Process {
        id: updateProcess
        command: ["bash", "-c", ""]
    }

    property bool isSaving: false
    property bool isUpdatingFromSettings: false

    function saveSettings() {
        if (isSaving || isUpdatingFromSettings) {
            console.log("Skipping save (isSaving:", isSaving, "isUpdatingFromSettings:", isUpdatingFromSettings, ")")
            return
        }
        
        const value = audioFeedbackCombo.currentValue
        if (value === Settings.audioFeedback) {
            console.log("Value already matches Settings, skipping")
            return
        }
        
        console.log("Saving audioFeedback:", value, "old value:", Settings.audioFeedback)
        
        isSaving = true
        // Prepara il comando
        const cmd = `python3 "${Paths.repoRoot}/scripts/updateSetting.py" audioFeedback "${value}"`
        console.log("Full command:", cmd)
        updateProcess.command = ["bash", "-c", cmd]
        updateProcess.running = true
        console.log("Process started")
        
        // Reset il flag dopo 2 secondi
        Qt.callLater(() => { isSaving = false }, 2000)
    }

    Connections {
        target: Settings
        function onAudioFeedbackChanged() {
            console.log("Settings.audioFeedback changed to:", Settings.audioFeedback)
            isUpdatingFromSettings = true
            audioFeedbackCombo.currentIndex = audioFeedbackOptions.indexOf(Settings.audioFeedback)
            Qt.callLater(() => { isUpdatingFromSettings = false })
        }
    }

    Component.onCompleted: {
        console.log("SettingsWindow loaded, current audioFeedback:", Settings.audioFeedback)
        console.log("Paths.repoRoot:", Paths.repoRoot)
        console.log("Script path:", Paths.repoRoot + "/scripts/updateSetting.py")
        audioFeedbackCombo.currentIndex = audioFeedbackOptions.indexOf(Settings.audioFeedback)
    }

    Rectangle {
        anchors.centerIn: parent
        width: parent.width
        height: parent.height
        color: Qt.alpha(Theme.background, Theme.panelOpacity)
        radius: 12
        border.color: Theme.border
        border.width: Theme.panelBorderWidth * 3

        ColumnLayout {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.leftMargin: 10
            anchors.rightMargin: 10
            spacing: 15

            // Audio Feedback Selector
            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                Text {
                    text: "Audio Feedback:"
                    color: Theme.foreground
                    Layout.alignment: Qt.AlignVCenter
                }

                ComboBox {
                    id: audioFeedbackCombo
                    model: audioFeedbackOptions
                    currentIndex: 0
                    Layout.fillWidth: true

                    onCurrentValueChanged: {
                        console.log("ComboBox value changed to:", currentValue)
                        // Evita di salvare se il valore non è cambiato
                        if (currentValue !== Settings.audioFeedback) {
                            saveSettings()
                        }
                    }

                    contentItem: Text {
                        leftPadding: 10
                        text: audioFeedbackCombo.currentText
                        color: Theme.foreground
                        verticalAlignment: Text.AlignVCenter
                    }

                    background: Rectangle {
                        color: Qt.alpha(Theme.background, 0.8)
                        border.color: Theme.border
                        border.width: 1
                        radius: 6
                    }
                }
            }

            Item { Layout.fillHeight: true }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 10
                PowerOffButton{}
                RebootButton{}
            }
        }

        MenuExit{
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.topMargin: 5
            anchors.rightMargin: 5
        }
    }
}