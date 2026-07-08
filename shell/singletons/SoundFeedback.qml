pragma Singleton
import QtQuick
import QtMultimedia
import qs.singletons

QtObject {
    id: root

    readonly property var profiles: ({
        "megalovania": {
            "type": "cycle",
            "files": [
                "megalovania-01.wav", "megalovania-02.wav", "megalovania-03.wav",
                "megalovania-04.wav", "megalovania-05.wav", "megalovania-06.wav",
                "megalovania-07.wav", "megalovania-08.wav", "megalovania-09.wav",
                "megalovania-10.wav"
            ]
        },
        "pop": {
            "type": "single",
            "files": ["pop.wav"]
        },
        "none": {
            "type": "single",
            "files": []
        }
    })

    property int cycleIndex: 0
    property var effectCache: ({})
    property real lastPlayTime: 0

    function getEffect(path) {
        if (!effectCache[path]) {
            effectCache[path] = Qt.createQmlObject(
                'import QtMultimedia; SoundEffect { source: "' + path + '" }',
                root
            );
        }
        return effectCache[path];
    }

    function currentProfile() {
        return profiles[Settings.audioFeedback] ?? profiles["none"]
    }

    function play() {
        const now = Date.now();
        if (now - root.lastPlayTime < 40) return;
        root.lastPlayTime = now;

        const profile = currentProfile();
        if (profile.files.length === 0) return;

        let file;
        if (profile.type === "cycle") {
            cycleIndex = (cycleIndex % profile.files.length) + 1;
            file = profile.files[cycleIndex - 1];
        } else {
            file = profile.files[0];
        }

        const url = Qt.resolvedUrl("../media/" + file);
        getEffect(url).play();
    }
}