pragma Singleton
import QtQuick
import Quickshell.Services.Mpris

QtObject {
    id: root
    property var _cachedPlayer: null

    readonly property var activePlayer: {
        var players = (Mpris && Mpris.players) ? Mpris.players.values : [];

        for (var i = 0; i < players.length; i++) {
            if (players[i].playbackState === MprisPlayer.Playing) {
                root._cachedPlayer = players[i];
                return players[i];
            }
        }

        var stillExists = players.some(p => p === root._cachedPlayer);
        if (stillExists) return root._cachedPlayer;

        return players.length > 0 ? players[0] : null;
    }
}
