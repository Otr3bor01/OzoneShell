pragma Singleton
import QtQuick
import QtQml
import Quickshell.Services.Mpris

QtObject {
    id: root

    property var activePlayer: null
    property var _playOrder: []   // player più recente in testa

    function _notifyStarted(player) {
        // rimuove eventuali occorrenze precedenti e lo rimette in testa
        root._playOrder = [player].concat(root._playOrder.filter(p => p !== player));
        root.updateActivePlayer();
    }

    function updateActivePlayer() {
        var players = (Mpris && Mpris.players) ? Mpris.players.values : [];

        // pulisce _playOrder da player non più esistenti
        root._playOrder = root._playOrder.filter(p => players.some(pl => pl === p));

        // cerca, in ordine di "ultimo avviato", il primo ancora in Playing
        var candidate = null;
        for (var i = 0; i < root._playOrder.length; i++) {
            if (root._playOrder[i].playbackState === MprisPlayer.Playing) {
                candidate = root._playOrder[i];
                break;
            }
        }

        if (!candidate) {
            // nessuno in play tra quelli tracciati: fallback al primo Playing trovato nella lista grezza
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