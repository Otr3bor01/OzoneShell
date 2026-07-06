import QtQuick
import QtMultimedia
import Quickshell.Services.Pipewire
import "../primitives"

Item {
    id: root
    width: 65
    height: 35

    PwObjectTracker { objects: [Pipewire.defaultAudioSink] }

    property real currentVolume: Pipewire.defaultAudioSink?.audio.volume ?? 0.0
    property var sink: Pipewire.defaultAudioSink
    property int megaCount: 0
    property real lastInputTime: 0
    property bool inPulse: false

    function increaseMegaCount() {
        megaCount = (megaCount < 10) ? megaCount + 1 : 1
    }

    function triggerPulse() {
        inPulse = true
        pulseTimer.restart()
    }

    Timer {
        id: pulseTimer
        interval: 50
        onTriggered: root.inPulse = false
    }

    MediaPlayer {
        id: popSound
        source: Qt.resolvedUrl("../media/pop.wav")
        audioOutput: AudioOutput {}
    }

    MediaPlayer {
        id: megalovania
        source: root.megaCount >= 1 && root.megaCount <= 10
            ? Qt.resolvedUrl("../media/megalovania-0" + root.megaCount + ".wav")
            : null
        audioOutput: AudioOutput {}
    }

    onCurrentVolumeChanged: {
        if (!sink || sink.audio.muted) return
        var now = Date.now()
        if (now - lastInputTime <= 40) return
        lastInputTime = now

        // Il tipo di feedback dipende da Settings.audioFeedback,
        // non è più fisso su Megalovania come nella versione originale.
        if (Settings.audioFeedback === "megalovania") {
            increaseMegaCount()
            megalovania.stop()
            megalovania.play()
        } else if (Settings.audioFeedback === "beep") {
            popSound.stop()
            popSound.play()
        }
        // "none" -> nessun suono

        triggerPulse()
    }

    HoverCapsule {
        id: capsule
        anchors.centerIn: parent
        baseWidth: 60
        hoverWidth: 65
        capsuleHeight: 30
        forceCompact: root.inPulse
        onWheel: (event) => {
            var delta = event.angleDelta.y !== 0 ? event.angleDelta.y : event.pixelDelta.y
            root.triggerPulse()
            if (!root.sink?.audio || delta === 0) return

            var step = 0.01
            var newVolume = root.currentVolume + (delta > 0 ? step : -step)

            if (root.sink.audio.muted) root.sink.audio.muted = false
            root.sink.audio.volume = Math.max(0.0, Math.min(1.0, newVolume))
            event.accepted = true
        }
        onClicked: {
            if (!root.sink?.audio) return
            root.triggerPulse()
            root.sink.audio.muted = !root.sink.audio.muted
        }

        content: Text {
            property string volSym: root.sink?.audio.muted ? "󰝟 "
                : (root.currentVolume * 100) === 0 ? "󰖁 "
                : (root.currentVolume * 100) < 33 ? "󰕿 "
                : (root.currentVolume * 100) < 66 ? "󰖀 " : "󰕾 "

            text: volSym + Math.round(root.currentVolume * 100) + "%"
            color: (root.currentVolume === 0 || root.sink?.audio.muted) ? "#FF0000" : Theme.accent
            font.family: Theme.fontFamily
            font.pixelSize: 16
        }
    }
}
