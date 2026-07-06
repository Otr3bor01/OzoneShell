import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell.Services.Mpris

Item {
    id: root
    implicitWidth: 300

    readonly property var activePlayer: MprisState.activePlayer

    RowLayout {
        anchors.centerIn: parent
        spacing: 6

        Text {
            text: ""
            font.pixelSize: 16
            color: Theme.accent
            font.family: "JetBrainsMono Nerd Font"
        }
        Text {
            text: root.activePlayer?.trackArtist ?? ""
            font.family: Theme.fontFamily
            font.bold: true
            font.pixelSize: 16
            color: Theme.foreground
            Layout.maximumWidth: 150
            elide: Text.ElideRight
        }
        Text { text: " " }
        Text {
            text: ""
            font.pixelSize: 16
            color: Theme.accent
            font.family: "JetBrainsMono Nerd Font"
        }
        Text {
            text: root.activePlayer ? (root.activePlayer.trackTitle ?? "!Unknown!") : ""
            Layout.maximumWidth: 250
            elide: Text.ElideRight
            font.family: Theme.fontFamily
            font.pixelSize: 16
            color: Theme.foreground
        }
        Text { text: "    " }

        Text {
            text: "󰒮"
            font.pixelSize: 30
            color: previousMouse.containsMouse ? Theme.foreground : Theme.accent
            MouseArea {
                id: previousMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: if (root.activePlayer?.canGoPrevious) root.activePlayer.previous()
            }
        }

        Item {
            Layout.preferredWidth: 25
            Layout.preferredHeight: 25

            Rectangle {
                anchors.fill: parent
                color: Theme.foreground
                radius: parent.width / 2
                Text {
                    anchors.centerIn: parent
                    text: "󰎇"
                    visible: coverImage.status !== Image.Ready
                    color: Theme.border
                    font.bold: true
                    font.pixelSize: 20
                }
            }

            Rectangle {
                id: mask
                anchors.fill: parent
                radius: parent.width / 2
                visible: false
                layer.enabled: true
            }

            Rectangle {
                id: bordino
                anchors.centerIn: mask
                radius: bordino.width / 2
                width: 28
                height: 28
                color: "transparent"
                border.color: Theme.accent
                z: 1
                border.width: 2
                antialiasing: true
            }

            Text {
                anchors.centerIn: mask
                text: root.activePlayer?.playbackState === MprisPlayer.Playing ? "" : ""
                color: playMouse.containsMouse ? Theme.foreground : Theme.accent
                font.bold: true
                font.pixelSize: 15
                z: 1
                MouseArea {
                    id: playMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: if (root.activePlayer) root.activePlayer.togglePlaying()
                }
            }

            Image {
                id: coverImage
                anchors.fill: parent
                source: {
                    if (!root.activePlayer) return "";
                    var url = root.activePlayer.artUrl?.toString() ?? "";
                    if (url === "" && root.activePlayer.metadata?.["mpris:artUrl"]) {
                        url = root.activePlayer.metadata["mpris:artUrl"].toString();
                    }
                    if (url === "") return "";
                    return url.startsWith("/") ? "file://" + url : url;
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
            color: nextMouse.containsMouse ? Theme.foreground : Theme.accent
            MouseArea {
                id: nextMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: if (root.activePlayer?.canGoNext) root.activePlayer.next()
            }
        }
    }
}
