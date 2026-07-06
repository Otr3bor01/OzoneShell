import Quickshell
import QtQuick
import "components"
import "modules"

ShellRoot {
    id: root
    settings.watchFiles: true
    Bar {}
}
