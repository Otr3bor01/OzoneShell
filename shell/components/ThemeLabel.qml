import QtQuick
import QtQuick.Layouts

RowLayout {
    spacing: 5

    Text {
        color: Theme.accent
        font.pixelSize: 18
        font.bold: true
        text: "✿"
    }
    Text {
        text: Theme.themeName
        color: Theme.foreground
        font.pixelSize: 18
        font.bold: true
        font.family: Theme.fontFamily
    }
    Text {
        color: Theme.accent
        font.pixelSize: 18
        font.bold: true
        text: "✿"
    }
}
