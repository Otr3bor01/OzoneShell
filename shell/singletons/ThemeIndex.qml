pragma Singleton
import Quickshell
import Quickshell.Io
import qs.singletons

Singleton {
    id: root
    property var themes: []

    FileView {
        path: Paths.themeIndexFile
        watchChanges: true
        onFileChanged: reload()
        onLoaded: {
            const data = JSON.parse(text())
            root.themes = data.themes
        }
    }
}