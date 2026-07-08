import QtQuick 
import Quickshell
import QtQuick.Layouts
import qs.components
import qs.singletons

RowLayout {
    Volume {
        id: volume
        baseWidth: 65
        hoverWidth: 70 // remember: height = baseWidth - 30
    }
    MenuButton {
        id: menuButton
        width: 35
    }

}