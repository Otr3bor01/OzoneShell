import QtQuick
import Quickshell
import qs.components

PanelWindow {
    aboveWindows: false
    anchors{
        bottom: false;
        left: true;
        top: true;
        right: true;
    }
    WorkspaceIndicator {}
}