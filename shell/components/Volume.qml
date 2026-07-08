import QtQuick
import Quickshell
import Quickshell.Services.Pipewire
import qs.singletons

Item {
    id: vol

    property int baseWidth: 65
    property int hoverWidth: 70

    width: hoverWidth   // il contenitore deve essere grande abbastanza da contenere lo stato più largo
    height: baseWidth - 30

    PwObjectTracker {
        objects: [ Pipewire.defaultAudioSink ]
    }

    property real currentVolume: Pipewire.defaultAudioSink?.audio.volume ?? 0.0
    property var sink: Pipewire.defaultAudioSink

    onCurrentVolumeChanged: {
        if (sink && !sink.audio.muted) {
            SoundFeedback.play();
            volume.triggerPulse2();
        }
    }

    Rectangle {
        id: volume
        property bool inPulse: false
        property bool inPulse2: false

        function triggerPulse() {
            volume.inPulse = true;
            pulseTimer.restart();
        }
        function triggerPulse2() {
            volume.inPulse2 = true;
            pulseTimer2.restart();
        }

        implicitWidth: vol.baseWidth
        implicitHeight: implicitWidth - 30
        radius: implicitWidth / 2
        anchors.centerIn: parent

        color: Qt.alpha(Theme.background, Theme.panelOpacity)
        border.width: Theme.panelBorderWidth
        border.color: Theme.border

        Timer {
            id: pulseTimer
            interval: 50
            repeat: false
            onTriggered: volume.inPulse = false
        }

        Timer {
            id: pulseTimer2
            interval: 50
            repeat: false
            onTriggered: volume.inPulse2 = false
        }

        Behavior on implicitWidth {
            NumberAnimation {
                duration: 100
                easing.type: Easing.OutCubic
            }
        }

        MouseArea {
            id: volumeMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.OpenHandCursor
            onWheel: (event) => {
                    let delta = event.angleDelta.y !== 0 ? event.angleDelta.y : event.pixelDelta.y;

                    volume.triggerPulse();

                    if (!vol.sink || !vol.sink.audio || delta === 0) return;

                    let step = 0.01;
                    let newVolume = vol.currentVolume;

                    if (delta > 0) {
                        newVolume += step;
                    } else if (delta < 0) {
                        newVolume -= step;
                    }

                    if (vol.sink.audio.muted) {
                        vol.sink.audio.muted = false;
                    }

                    vol.sink.audio.volume = Math.max(0.0, Math.min(1.0, newVolume));
                    event.accepted = true;
            }
            onClicked: (mouse) => {
                if (!vol.sink || !vol.sink.audio) return;

                volume.triggerPulse();

                vol.sink.audio.muted = !vol.sink.audio.muted
            }
        }

        states: [
            State {
                name: "hovered"
                when: volumeMouse.containsMouse
                PropertyChanges {
                    target: volume
                    implicitWidth: (inPulse || inPulse2) ? vol.baseWidth : vol.hoverWidth
                    border.color: Theme.activeBorder
                    border.width: Theme.panelBorderWidth + 0.5
                }
            },
            State {
                name: "default"
                when: !volumeMouse.containsMouse
                PropertyChanges {
                    target: volume
                    implicitWidth: inPulse2 ? vol.hoverWidth : vol.baseWidth
                    border.color: Theme.inactiveBorder
                    border.width: Theme.panelBorderWidth
                }
            }
        ]

        Text {
            property var volSym: (vol.sink.audio.muted) ? "󰝟 ":
                                 (vol.currentVolume*100) === 0 ? "󰖁 " :
                                 (vol.currentVolume * 100) < 33 ? "󰕿 ":
                                 (vol.currentVolume * 100) < 66 ? "󰖀 ": "󰕾 "

            anchors.centerIn: parent
            text: volSym + Math.round(vol.currentVolume*100) + "%"
            color: vol.currentVolume == 0 ? "#FF0000" :
                   vol.sink.audio.muted ? "#FF0000" : Theme.icons
            font.family: Theme.fontFamily
            font.pixelSize: 16
        }
    }
}