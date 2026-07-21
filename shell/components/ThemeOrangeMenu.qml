// AI re-made, WIP
import QtQuick
import Quickshell
import Quickshell.Io
import qs.singletons

Item {
    id: root
    anchors.centerIn: parent
    width: raggio
    height: raggio

    // Radius (just while making)
    property int raggio: 500

    readonly property var themes: ThemeIndex.themes
    readonly property int sliceCount: themes.length

    property int hoveredIndex: -1

    readonly property real cx: width / 2
    readonly property real cy: height / 2
    readonly property real radius: Math.min(width, height) / 2 - 10

    signal sliceClicked(int index)
    signal themeSelected(string themeFile)

    function sliceIndexAt(mx, my) {
        if (sliceCount === 0) return -1
        var dx = mx - cx
        var dy = my - cy
        var dist = Math.sqrt(dx * dx + dy * dy)
        if (dist > radius) return -1
        var angle = Math.atan2(dy, dx) + Math.PI / 2
        if (angle < 0) angle += 2 * Math.PI
        var sliceAngle = (2 * Math.PI) / sliceCount
        return Math.floor(angle / sliceAngle)
    }

    onThemesChanged: canvas.requestPaint()

    // Runs applyTheme.py and only signals completion once the process
    // has actually exited, instead of firing-and-forgetting like
    // Quickshell.execDetached did. This removes the race condition
    // where the menu/theme index was read before the script finished.
    Process {
        id: applyThemeProcess

        property string pendingThemeFile: ""
        property bool busy: false

        command: ["python3", Paths.applyThemeScript, pendingThemeFile]

        onExited: (exitCode, exitStatus) => {
            busy = false
            if (exitCode === 0) {
                // Safety net: force a re-read in case the FileView's
                // watcher missed or debounced the change.
                ThemeIndex.reload()
            } else {
                console.warn("applyTheme.py exited with code", exitCode)
            }
        }

        function run(themeFile) {
            if (busy) {
                console.warn("applyThemeProcess already running, ignoring click")
                return
            }
            pendingThemeFile = themeFile
            busy = true
            running = true
        }
    }

    Canvas {
        id: canvas
        anchors.fill: parent
        onPaint: {
            var ctx = getContext("2d")
            ctx.reset()
            if (root.sliceCount === 0) return

            var sliceAngle = (2 * Math.PI) / root.sliceCount
            for (var i = 0; i < root.sliceCount; i++) {
                var theme = root.themes[i]
                var start = i * sliceAngle - Math.PI / 2
                var end = start + sliceAngle

                ctx.beginPath()
                ctx.moveTo(root.cx, root.cy)
                ctx.arc(root.cx, root.cy, root.radius, start, end)
                ctx.closePath()

                var baseColor = theme.background
                ctx.fillStyle = (i === root.hoveredIndex) ? Qt.lighter(baseColor, 1.3) : baseColor
                ctx.fill()
                ctx.strokeStyle = Theme.icons
                ctx.lineWidth = 2
                ctx.stroke()

                var mid = start + sliceAngle / 2
                var labelR = root.radius * 0.65
                var lx = root.cx + labelR * Math.cos(mid)
                var ly = root.cy + labelR * Math.sin(mid)

                ctx.fillStyle = theme.foreground
                ctx.font = "14px " + (theme.fontFamily || "sans-serif")
                ctx.textAlign = "center"
                ctx.textBaseline = "middle"
                ctx.fillText(theme.symbol + " " + theme.name, lx, ly)
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onPositionChanged: {
            var idx = root.sliceIndexAt(mouseX, mouseY)
            if (idx !== root.hoveredIndex) {
                root.hoveredIndex = idx
                canvas.requestPaint()
            }
        }
        onExited: {
            root.hoveredIndex = -1
            canvas.requestPaint()
        }
        onClicked: {
            var idx = root.sliceIndexAt(mouseX, mouseY)
            if (idx >= 0) {
                var themeFile = root.themes[idx].file
                root.sliceClicked(idx)
                root.themeSelected(themeFile)
                applyThemeProcess.run(themeFile)
            }
            canvas.requestPaint()
        }
    }
}
