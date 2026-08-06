import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import qs.singletons

RowLayout {
    id: root
    property string label: ""
    property int displayNum: 1
    property int value: displayNum === 1 ? BrightnessState.brightnessDP1 : BrightnessState.brightnessDP2

    spacing: 10
    Layout.fillWidth: true

    Text {
        text: root.label + Math.round(slider.value) + " \u{f0cf2}"
        color: Theme.foreground
        Layout.alignment: Qt.AlignVCenter
    }
    Slider {
        id: slider
        Layout.fillWidth: true
        from: 0
        to: 100
        stepSize: 1
        value: root.value
        onMoved: {
            if (root.displayNum === 1) BrightnessState.setDP1(Math.round(value))
            else BrightnessState.setDP2(Math.round(value))
        }
        background: Rectangle {
            x: slider.leftPadding
            y: slider.topPadding + slider.availableHeight / 2 - height / 2
            width: slider.availableWidth
            height: 4
            radius: 2
            color: Qt.alpha(Theme.background, 0.8)
            border.color: Theme.border
            Rectangle {
                width: slider.visualPosition * parent.width
                height: parent.height
                radius: 2
                color: Theme.foreground
            }
        }
        handle: Rectangle {
            x: slider.leftPadding + slider.visualPosition * (slider.availableWidth - width)
            y: slider.topPadding + slider.availableHeight / 2 - height / 2
            width: 16
            height: 16
            radius: 8
            color: Theme.foreground
            border.color: Theme.border
        }
    }
    Text {
        text: Math.round(slider.value) == 0 ? "\u{f00da}" :
                Math.round(slider.value) < 20 ? "\u{f00db}" : 
                Math.round(slider.value) < 40 ? "\u{f00dc}" :
                Math.round(slider.value) < 60 ? "\u{f00dd}" : 
                Math.round(slider.value) < 80 ? "\u{f00de}" :
                Math.round(slider.value) < 100 ? "\u{f00df}" :
                Math.round(slider.value) == 100 ? "\u{f00e0}" :
                "?"
        font.pixelSize: 24
        font.family: Theme.fontFamilyIcons
        color: Theme.icons
        Layout.preferredWidth: 40
    }
}