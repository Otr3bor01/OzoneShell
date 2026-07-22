import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Mpris
import Quickshell.Widgets
import QtQuick.Effects
import qs.singletons

Item {
    id: root

    readonly property var activePlayer: MprisState.activePlayer

    implicitWidth: 300
    Layout.rightMargin: 200
    Layout.leftMargin: 200
    Layout.alignment: Qt.AlignHCenter

    RowLayout {
        id: content
        anchors.centerIn: parent
        spacing: 6

        Text {
            text: "\uf130"
            font.pixelSize: Theme.fontSizeNormal
            font.family: Theme.fontFamilyIcons
            color: Theme.icons
        }

        Text { // artist
            text: root.activePlayer?.trackArtist || "Unknown artist"
            font.family: Theme.fontFamily
            font.bold: true
            font.pixelSize: Theme.fontSizeNormal
            color: Theme.foreground
            Layout.maximumWidth: 150
            elide: Text.ElideRight
        }

        Text { //spacer
            text: " "
        }

        Text {
            text: "\uf001"
            font.pixelSize: Theme.fontSizeNormal
            font.family: Theme.fontFamilyIcons
            color: Theme.icons
        }

        Text { // title
            text: root.activePlayer?.trackTitle || "No track"
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeNormal
            color: Theme.foreground
            Layout.maximumWidth: 250
            elide: Text.ElideRight
        }

        Text { // spacer
            text: "    "
        }

        Text { // previous
            text: "\uf048"
            font.pixelSize: 23
            color: previousMouse.containsMouse ? Theme.brightWhite : Theme.icons

            MouseArea {
                id: previousMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: if (root.activePlayer?.canGoPrevious) root.activePlayer.previous()
            }
        }

        Item { // cover + play/pause
            id: coverContainer
            Layout.preferredWidth: 25
            Layout.preferredHeight: 25

            Rectangle { // fallback
                anchors.fill: parent
                color: Theme.brightWhite
                radius: width / 2

                Text {
                    anchors.centerIn: parent
                    text: "\u{f0387}"
                    visible: coverImage.status !== Image.Ready
                    color: Theme.background
                    font.bold: true
                    font.pixelSize: 20
                }
            }

            Rectangle { // mask
                id: mask
                anchors.fill: parent
                radius: width / 2
                visible: false
                layer.enabled: true
            }

            Rectangle { // border
                id: bordino
                anchors.centerIn: mask
                width: 28
                height: 28
                radius: width / 2
                color: "transparent"
                border.color: Theme.icons
                border.width: Theme.panelBorderWidth
                z: 1
                antialiasing: true
            }

            Text { // play/pause icon
                anchors.centerIn: mask
                text: root.activePlayer?.playbackState === MprisPlayer.Playing ? "\uf04c" : "\uf04b"
                color: playMouse.containsMouse ? Theme.brightWhite : Theme.icons
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
                fillMode: Image.PreserveAspectCrop
                source: {
                    if (!root.activePlayer) return "";
                    var url = root.activePlayer.artUrl?.toString() ?? "";
                    if (url === "" && root.activePlayer.metadata?.["mpris:artUrl"]) {
                        url = root.activePlayer.metadata["mpris:artUrl"].toString();
                    }
                    if (url === "") return "";
                    return url.startsWith("/") ? "file://" + url : url;
                }

                layer.enabled: true
                layer.effect: MultiEffect {
                    maskEnabled: true
                    maskSource: mask
                }
            }
        }

        Text { // next
            text: "\uf051"
            font.pixelSize: 23
            color: nextMouse.containsMouse ? Theme.brightWhite : Theme.icons

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