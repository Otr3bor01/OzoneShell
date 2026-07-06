import Quickshell
import QtQuick
import Quickshell.Io
import Quickshell.Hyprland
import Quickshell.Services.Mpris
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell.Services.Pipewire
import QtQuick.Controls
import QtMultimedia

PanelWindow {
    //===Basics
    id: root
    screen: Quickshell.screens.find(s => s.name === "DP-1")
    aboveWindows: false
    anchors{
        bottom: false;
        left: true;
        top: true;
        right: true;
    }
    margins{
        left: 10;
        top: 10;
        right: 10;
    }
    implicitHeight: 35
    color: "transparent"
    //===FileView for the workspace system
    FileView {
        id: monitorState
        path: "/tmp/hypr_secondMonitor"
        watchChanges: true
        onFileChanged: reload()
    }


    //===Mpris property bind
    QtObject {
        id: internalState
        readonly property var cache: ({ player: null })
    }

    property var activePlayer: {
        var players = (Mpris && Mpris.players) ? Mpris.players.values : [];
        
        var playingPlayer = null;
        for (var j = 0; j < players.length; j++) {
            if (players[j].playbackState === MprisPlayer.Playing) {
                playingPlayer = players[j];
                break;
            }
        }

        if (playingPlayer) {
            internalState.cache.player = playingPlayer;
            return playingPlayer;
        }

        var cached = internalState.cache.player;
        var exists = false;
        for (var k = 0; k < players.length; k++) {
            if (players[k] === cached) {
                exists = true;
                break;
            }
        }

        return exists ? cached : (players.length > 0 ? players[0] : null);
    }

    //===Row
    Row{
        anchors.fill: parent
        spacing: 5
        //workspace indicator
        Rectangle {
            id: workspaceIndicator
            implicitWidth: 290
            implicitHeight: 35
            color: Qt.rgba(18/255, 13/255, 30/255, 0.5)
            radius: 100
            border.color: monitorState.text().trim() === "false" ? "#D9D0E8" : "#443355"
            border.width: 1.5
            Row {
                anchors.fill: parent
                anchors.centerIn: parent
                spacing: 6
                padding: 8
                Repeater {
                    model: Hyprland.workspaces.values.filter(ws => ws.id > 0 && ws.id <= 5)
                    delegate: Rectangle {
                        width: 50
                        height: 10
                        radius: 5
                        color: modelData.active 
                            ?  "#C87DD4"
                            : Qt.rgba(18/255, 13/255, 30/255, 0.5)
                        border.color: modelData.active 
                            ? "#D9D0E8" 
                            : mouseArea.containsMouse 
                                ? Qt.rgba(0.85, 0.82, 0.91, 0.5)
                                : "#2C2C2E"
                        border.width: 2
                        anchors.verticalCenter: parent.verticalCenter
                        //on click change workspace
                        MouseArea {
                            id: mouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                Hyprland.dispatch("hl.dsp.focus({ workspace = " + modelData.id + " })")
                            }
                        }
                    }
                }
            }
        }
        //spacer 
        Rectangle {
            width: 150
            height: 100
            color: "transparent"
        }
        //Center Bar
        Rectangle {
            implicitWidth: 1000
            implicitHeight: 35
            color: Qt.rgba(18/255, 13/255, 30/255, 0.5)
            radius: 100
            border.color: "#443355"
            border.width: 1.5
            //Center Bar Row
            RowLayout {
                id: centralBar
                anchors.fill: parent
                anchors.centerIn: parent
                spacing: 30
                //Theme Changer Interface (WIP)
                Item{
                    id: themeName
                    Layout.alignment: Qt.AlignVCenter
                    Layout.leftMargin: 60
                    Layout.bottomMargin: 0
                    
                    RowLayout {
                        spacing: 5
                        anchors.centerIn: parent
                        Text {
                            color: "#C87DD4"
                            font.pixelSize: 18
                            font.bold: true
                            text: "✿"
                        }
                        Text {
                            text: "Pansy"
                            color: "#D9D0E8"
                            font.pixelSize: 18
                            font.bold: true
                            font.family: "Iosevka"
                        }
                        Text {
                            color: "#C87DD4"
                            font.pixelSize: 18
                            font.bold: true
                            text: "✿"
                        }
                    }
                }
                //Mpris Row
                Item {
                    implicitWidth: 300
                    Layout.rightMargin: 200
                    Layout.leftMargin: 200
                    Layout.alignment: Qt.AlignHCenter
                    RowLayout {
                        anchors.centerIn: parent
                        spacing: 6
                        Text {
                            text: ""
                            font.pixelSize: 16
                            color: "#C87DD4"
                            font.family: "JetBrainsMono Nerd Font"
                        }
                        Text { //artist
                            text: {
                                if (!activePlayer) return "No player";
                                
                                var artist = activePlayer.trackArtist ? activePlayer.trackArtist : "";
                                
                                return artist !== "" ? artist : artist
                            }
                            font.family: "Iosevka"
                            font.bold: true
                            font.pixelSize: 16
                            color: "#D9D0E8"

                            Layout.maximumWidth: 150
                            elide: Text.ElideRight 
                        }
                        Text {
                            text: " "
                        }
                        Text {
                            text: ""
                            font.pixelSize: 16
                            color: "#C87DD4"
                            font.family: "JetBrainsMono Nerd Font"
                        }
                        Text {
                            text: {
                                if (!activePlayer) return "";

                                var title = activePlayer.trackTitle ? activePlayer.trackTitle : "!Unknown!";

                                return title !== "!Unknown!" ? title : title
                            }
                            Layout.maximumWidth: 250 
                            elide: Text.ElideRight 
                            font.family: "Iosevka"
                            font.pixelSize: 16
                            color: "#D9D0E8"
                        }

                        Text { //spacer
                            text: "    "
                        }

                        
                        Text { //previous
                            text: "󰒮"
                            font.pixelSize: 30
                            color: previousMouse.containsMouse ? "#D9D0E8" : "#C87DD4"
                            
                            MouseArea {
                                id: previousMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: if (activePlayer && activePlayer.canGoPrevious) activePlayer.previous()
                            }
                        }
                        Item { //cover and pause
                            Layout.preferredWidth: 25
                            Layout.preferredHeight: 25

                            Rectangle { //fallback
                                anchors.fill: parent
                                color: "#D9D0E8"
                                radius: parent.width/2
                                
                                Text {
                                    anchors.centerIn: parent
                                    text: "󰎇"
                                    visible: parent.parent.children[2].status !== Image.Ready
                                    color: "#443355"
                                    font.bold: true
                                    font.pixelSize: 20
                                }
                            }

                            Rectangle { //mask
                                id: mask
                                anchors.fill: parent
                                radius: parent.width/2
                                visible: false 
                                layer.enabled: true 
                            }

                            Rectangle { //border
                                id: bordino
                                anchors.centerIn: mask
                                radius: bordino.width/2
                                width: 28
                                height: 28
                                color: "transparent"
                                border.color: "#C87DD4"
                                z: 1
                                border.width: 2

                                antialiasing: true
                            }
                            Text { //pause
                                anchors.centerIn: mask
                                text: activePlayer && activePlayer.playbackState === MprisPlayer.Playing ? "" : ""
                                color: playMouse.containsMouse ? "#D9D0E8" : "#C87DD4"
                                MouseArea {
                                    id: playMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: if (activePlayer) activePlayer.togglePlaying()
                                }
                                font.bold: true
                                font.pixelSize: 15
                                z: 1
                            }
                            Image {
                                id: coverImage
                                anchors.fill: parent
                                
                                source: {
                                    if (!activePlayer) return "";
                                    var url = "";
                                    if (activePlayer.artUrl) url = activePlayer.artUrl.toString();
                                    if (url === "" && activePlayer.metadata && activePlayer.metadata["mpris:artUrl"]) {
                                        url = activePlayer.metadata["mpris:artUrl"].toString();
                                    }
                                    if (url === "") return "";
                                    if (url.startsWith("/")) return "file://" + url;
                                    return url;
                                }
                                
                                fillMode: Image.PreserveAspectCrop
                                
                                layer.enabled: true
                                layer.effect: MultiEffect {
                                    maskEnabled: true
                                    maskSource: mask
                                }
                            }
                        }

                        Text {
                            text: "󰒭"
                            font.pixelSize: 30
                            color: nextMouse.containsMouse ? "#D9D0E8" : "#C87DD4"

                            MouseArea {
                                id: nextMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: if (activePlayer && activePlayer.canGoNext) activePlayer.next()
                            }
                        }
                    }
                }
                //Time and Date (WIP)
                Item{
                    id: dateTime
                    property var currentTime: new Date()
                    Layout.alignment: Qt.AlignVCenter
                    Layout.rightMargin: 100
                    Layout.bottomMargin: 0
                    Timer{
                        interval: 1000
                        running: true
                        repeat: true
                        onTriggered: parent.currentTime = new Date()
                    }
                    
                    RowLayout{
                        anchors.centerIn: parent
                        spacing: 2
                        Text{
                            text: ""
                            color: "#C87DD4"
                            font.pixelSize: 18
                            font.bold: true
                        }
                        Text{
                            text: Qt.formatDateTime(dateTime.currentTime, "hh:mm") 
                            color: "#D9D0E8"
                            font.pixelSize: 16
                            font.bold: true
                            font.family: "Iosevka"
                        }
                        Text{
                            text:"      "
                        }
                        Text{
                            text: ""
                            color: "#C87DD4"
                            font.pixelSize: 18
                            font.bold: true
                        }
                        Text{
                            text: Qt.formatDateTime(dateTime.currentTime, "dd/MM/yyyy") 
                            color: "#D9D0E8"
                            font.pixelSize: 16
                            font.bold: true
                            font.family: "Iosevka"
                        }
                    }

                    
                }

            }

        }

        //spacer 
        Rectangle {
            width: 250
            height: 100
            color: "transparent"
        }
        Item{   //menù work in progress
            width: 35
            height: 35
            anchors.verticalCenter: parent.verticalCenter
            Rectangle {
                id: archMenu
                implicitWidth: 30
                implicitHeight: implicitWidth
                radius: implicitWidth / 2
                anchors.centerIn: parent

                color: Qt.rgba(18/255, 13/255, 30/255, 0.5)
                border.color: "#443355"


                //first animation!!
                Behavior on implicitWidth {
                    NumberAnimation {
                        duration: 150
                        easing.type: Easing.OutCubic
                    }
                }

                MouseArea {
                    id: archMenuMouse
                    anchors.fill: parent
                    hoverEnabled: true
                }
                
                states: [ //first time using states
                    State {
                        name: "hovered"
                        when: archMenuMouse.containsMouse
                        PropertyChanges {
                            target: archMenu
                            implicitWidth: 35
                            border.color: "#C87DD4"
                            border.width: 2
                        }
                    },

                    State {
                        name: "default"
                        when: !archMenuMouse.containsMouse
                        PropertyChanges {
                            target: archMenu
                            implicitWidth: 30
                        }
                    }
                ]
            }
            Text {
                anchors.centerIn: parent
                text: "󰣇"
                font.pixelSize : 20
                color: "#C87DD4"
            }
        }
        Item{ //volume
            //quando si alza e si abbassa il volume deve fare un piccolo battito ed un suono di verifica --> Megalovania
            id: vol
            width: 65
            height: 35
            anchors.verticalCenter: parent.verticalCenter
            PwObjectTracker {
                    objects: [ Pipewire.defaultAudioSink ]
            }
            property real currentVolume: Pipewire.defaultAudioSink?.audio.volume ?? 0.0
            property var sink: Pipewire.defaultAudioSink
            property int megaCount : 0
            property real lastInputTime: 0

            function increaseMegaCount() {
                if (vol.megaCount < 10) {
                    vol.megaCount += 1
                } else {
                    vol.megaCount = 1
                }
            }

            MediaPlayer {
                id: popSound
                source: Qt.resolvedUrl("media/pop.wav")
                audioOutput: AudioOutput {}
            }

            MediaPlayer {
                id: megalovania
                source: vol.megaCount === 1 ? Qt.resolvedUrl("media/megalovania-01.wav") :
                        vol.megaCount === 2 ? Qt.resolvedUrl("media/megalovania-02.wav") :
                        vol.megaCount === 3 ? Qt.resolvedUrl("media/megalovania-03.wav") :
                        vol.megaCount === 4 ? Qt.resolvedUrl("media/megalovania-04.wav") :
                        vol.megaCount === 5 ? Qt.resolvedUrl("media/megalovania-05.wav") :
                        vol.megaCount === 6 ? Qt.resolvedUrl("media/megalovania-06.wav") :
                        vol.megaCount === 7 ? Qt.resolvedUrl("media/megalovania-07.wav") :
                        vol.megaCount === 8 ? Qt.resolvedUrl("media/megalovania-08.wav") :
                        vol.megaCount === 9 ? Qt.resolvedUrl("media/megalovania-09.wav") :
                        vol.megaCount === 10 ? Qt.resolvedUrl("media/megalovania-10.wav") : null
                audioOutput: AudioOutput {}
            }

            onCurrentVolumeChanged: {
                if (sink && !sink.audio.muted) {
                    let currentTime = Date.now();
                    if (currentTime - vol.lastInputTime > 40) {
                        vol.lastInputTime = currentTime;                    
                        vol.increaseMegaCount()
                        megalovania.stop();
                        megalovania.play();

                        volume.triggerPulse2();
                    }
                }
            }
            Rectangle {
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
                id: volume
                implicitWidth: 60
                implicitHeight: implicitWidth - 30
                radius: implicitWidth / 2
                anchors.centerIn: parent

                color: Qt.rgba(18/255, 13/255, 30/255, 0.5)
                border.color: "#443355"

                Timer { //PulseTimer
                    id: pulseTimer
                    interval: 50
                    repeat: false
                    onTriggered: volume.inPulse = false
                }

                Timer { //PulseTimer2
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
                            //Fallback
                            let delta = event.angleDelta.y !== 0 ? event.angleDelta.y : event.pixelDelta.y;
                            //

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
                            implicitWidth: inPulse || inPulse2 ? 60 : 65
                            border.color: "#C87DD4"
                            border.width: 2
                        }
                    },

                    State {
                        name: "default"
                        when: !volumeMouse.containsMouse
                        PropertyChanges {
                            target: volume
                            implicitWidth: inPulse2? 65 : 60
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
                           vol.sink.audio.muted ? "#FF0000" : "#C87DD4"
                    font.family: "Iosevka"
                    font.pixelSize:16
                }
            }
        }
        Item { //updates
            id: updates
            property int updateCount: 0
            width: 65
            height: 35
            anchors.verticalCenter: parent.verticalCenter

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
                    if (ticks >= 20) {  // dopo 10 minuti si ferma
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
                implicitWidth: 60
                implicitHeight: implicitWidth - 30
                radius: implicitWidth / 2
                anchors.centerIn: parent
                color: Qt.rgba(18/255, 13/255, 30/255, 0.5)
                border.color: "#443355"

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
                            implicitWidth: 65
                            border.color: "#C87DD4"
                            border.width: 2
                        }
                    },
                    State {
                        name: "default"
                        when: !archUpdatesMouse.containsMouse
                        PropertyChanges {
                            target: archUpdates
                            implicitWidth: 60
                            border.color: "#443355"
                        }
                    }
                ]

                RowLayout {
                    anchors.centerIn: parent
                    spacing: 4

                    Text {
                        text: "󰚰"
                        font.pixelSize: 16
                        color: "#C87DD4"
                        Layout.alignment: Qt.AlignVCenter
                    }

                    Text {
                        text: updates.updateCount > 0 ? updates.updateCount : "0"
                        color: updates.updateCount > 0 ? "#D9D0E8" : "#C87DD4"
                        font.pixelSize: 16
                        Layout.alignment: Qt.AlignVCenter
                        font.family: "Iosevka"
                    }
                }
            }
        }
    }
}
