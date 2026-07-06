import QtQuick
import Quickshell
import Quickshell.Services.DBusMenu

ShellRoot {
    DBusItem {
        id: dbusRegistry
        bus: DBus.SessionBus
        service: "org.freedesktop.DBus"
        path: "/org/freedesktop/DBus"
        interfaceName: "org.freedesktop.DBus"

        Component.onCompleted: {
            // Chiamiamo ListNames sul bus di sistema
            dbusRegistry.callMethod("ListNames", [], function(result) {
                console.log("--- LISTA SERVIZI DBUS VISTI DA QUICKSHELL ---");
                var trovatoMpris = false;
                
                for (var i = 0; i < result.length; i++) {
                    if (result[i].indexOf("org.mpris.MediaPlayer2") !== -1) {
                        console.log("👉 " + result[i]);
                        trovatoMpris = true;
                    }
                }
                
                if (!trovatoMpris) {
                    console.log("❌ Quickshell non vede NESSUN player multimediale registrato su DBus.");
                }
            });
        }
    }
}