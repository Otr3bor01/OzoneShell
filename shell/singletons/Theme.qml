pragma Singleton
import QtQuick
import Quickshell.Io

QtObject {
    id: root

    // Nomi semantici invece di leggere hex sparsi in ogni file:
    // se un domani rinomini una chiave nel JSON, cambi solo qui.
    property var _data: ({})

    readonly property string themeName: _data.theme_name ?? "Ozone"
    readonly property string themeSymbol: _data.theme_symbol ?? "󰯙"

    //=====================
    //===Colors: normal====
    //=====================
    readonly property color normalBlack:   _data.colors?.normal?.black  ?? "#1A1228"
    readonly property color normalRed:     _data.colors?.normal?.red   ?? "#C94F6B"
    readonly property color normalGreen:   _data.colors?.normal?.green ?? "#5A8A5E"
    readonly property color normalYellow:  _data.colors?.normal?.yellow ?? "#C98A2A"
    readonly property color normalPurple:  _data.colors?.normal?.purple ?? "#5C4BA0"
    readonly property color normalPink:    _data.colors?.normal?.pink  ?? "#9B4FA6"
    readonly property color normalBlue:    _data.colors?.normal?.blue  ?? "#7A9EBF"
    readonly property color normalWhite:   _data.colors?.normal?.white ?? "#D9D0E8"

    //=====================
    //===Colors: bright====
    //=====================
    readonly property color brightBlack:   _data.colors?.bright?.black  ?? "#352748"
    readonly property color brightRed:     _data.colors?.bright?.red   ?? "#E8718E"
    readonly property color brightGreen:   _data.colors?.bright?.green ?? "#7ABF7E"
    readonly property color brightYellow:  _data.colors?.bright?.yellow ?? "#F0B84A"
    readonly property color brightPurple:  _data.colors?.bright?.purple ?? "#9580D6"
    readonly property color brightPink:    _data.colors?.bright?.pink  ?? "#C87DD4"
    readonly property color brightBlue:    _data.colors?.bright?.blue  ?? "#A8C8E8"
    readonly property color brightWhite:   _data.colors?.bright?.white ?? "#F2EEF9"

    //=====================
    //===Colors: special====
    //=====================
    readonly property color background:       _data.colors?.special?.background      ?? "#120D1E"
    readonly property color foreground:        _data.colors?.special?.foreground       ?? "#D9D0E8"
    readonly property color icons:              _data.colors?.special?.icons            ?? "#C87DD4"
    readonly property color accent:              _data.colors?.special?.accent           ?? "#C87DD4"
    readonly property color border:               _data.colors?.special?.border           ?? "#443355"
    readonly property color activeBorder:           _data.colors?.special?.active_border    ?? "#C87DD4"
    readonly property color inactiveBorder:          _data.colors?.special?.inactive_border  ?? "#443355"
    readonly property color errorColor:               _data.colors?.special?.error            ?? "#C94F6B"
    readonly property color warningColor:              _data.colors?.special?.warning          ?? "#C98A2A"
    readonly property color successColor:               _data.colors?.special?.success          ?? "#5A8A5E"

    //=====================
    //========Fonts=========
    //=====================
    readonly property string fontFamily:       _data.fonts?.family        ?? "Iosevka"
    readonly property string fontFamilyMono:   _data.fonts?.family_mono   ?? "JetBrainsMono Nerd Font"
    readonly property string fontFamilyIcons:  _data.fonts?.family_icons  ?? "JetBrainsMono Nerd Font"
    readonly property int fontSizeSmall:       _data.fonts?.size_small    ?? 12
    readonly property int fontSizeNormal:      _data.fonts?.size_normal   ?? 16
    readonly property int fontSizeLarge:       _data.fonts?.size_large    ?? 20
    readonly property string fontWeightNormal: _data.fonts?.weight_normal ?? "regular"
    readonly property string fontWeightBold:   _data.fonts?.weight_bold   ?? "bold"

    //=====================
    //=====Quickshell========
    //=====================
    // Questi sono specifici del pannello (opacità, raggi, spessori) e non
    // duplicano i colori di base: quelli restano sopra in "special".
    readonly property real panelOpacity:      _data.quickshell?.panel_opacity      ?? 0.5
    readonly property real panelRadius:        _data.quickshell?.panel_radius        ?? 100
    readonly property real panelBorderWidth:    _data.quickshell?.panel_border_width  ?? 1.5

    readonly property color iconActive:          _data.quickshell?.icon_active         ?? brightPink
    readonly property color iconInactive:         _data.quickshell?.icon_inactive        ?? brightBlack
    readonly property color pulseColor:            _data.quickshell?.pulse_color          ?? accent

    //=====================
    //=====FileView==========
    //=====================
    // QtObject non ha una default property: il FileView va assegnato
    // esplicitamente, altrimenti QML dà "Cannot assign to non-existent
    // default property" (come già visto in passato).
    property FileView themeFile: FileView {
        id: themeFile
        path: "/home/otr3bor/.config/quickshell/state/theme.json"
        watchChanges: true
        onFileChanged: reload()
        onLoaded: {
            try {
                root._data = JSON.parse(text())
            } catch (e) {
                console.warn("Theme.qml: JSON non valido, mantengo i valori precedenti", e)
            }
        }
    }
}
