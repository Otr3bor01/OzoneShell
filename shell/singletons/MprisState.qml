pragma Singleton
import QtQuick
import QtQml
import Quickshell.Services.Mpris

QtObject {
    id: root

    property var activePlayer: null
    property var _playOrder: []   //most recent player first

    function _notifyStarted(player) {
        // put again the player that just started at the top of the list, so it will be preferred if still playing
        root._playOrder = [player].concat(root._playOrder.filter(p => p !== player));
        root.updateActivePlayer();
    }

    function updateActivePlayer() {
        var players = (Mpris && Mpris.players) ? Mpris.players.values : [];

        // remove non-existing players from the play order list
        root._playOrder = root._playOrder.filter(p => players.some(pl => pl === p));

        // last started player that is still playing is the preferred one
        var candidate = null;
        for (var i = 0; i < root._playOrder.length; i++) {
            if (root._playOrder[i].playbackState === MprisPlayer.Playing) {
                candidate = root._playOrder[i];
                break;
            }
        }

        if (!candidate) {
            // no one is playing among the tracked players: fallback to the first Playing player found in the raw list
            for (var j = 0; j < players.length; j++) {
                if (players[j].playbackState === MprisPlayer.Playing) {
                    candidate = players[j];
                    break;
                }
            }
        }

        if (!candidate) {
            var stillExists = players.some(p => p === root.activePlayer);
            candidate = stillExists ? root.activePlayer : (players.length > 0 ? players[0] : null);
        }

        root.activePlayer = candidate;
    }

    Component.onCompleted: updateActivePlayer()

    property Connections _listConn: Connections {
        target: Mpris.players
        function onValuesChanged() { root.updateActivePlayer() }
    }

    property Instantiator _stateWatchers: Instantiator {
        model: Mpris.players.values
        delegate: Connections {
            target: modelData
            function onPlaybackStateChanged() {
                if (modelData.playbackState === MprisPlayer.Playing) {
                    root._notifyStarted(modelData);
                } else {
                    root.updateActivePlayer();
                }
            }
        }
    }
}