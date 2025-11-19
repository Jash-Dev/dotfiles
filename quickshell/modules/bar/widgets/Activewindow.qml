import QtQuick
import Quickshell
import Quickshell.Hyprland as Hypr

Row {
    id: root
    spacing: 8

    // size based on text
    height: titleText.implicitHeight
    width: Math.min(titleText.implicitWidth, 400)

    // active window, but ONLY if it's on the focused workspace
    property var activeOnCurrent: (
        Hypr.Hyprland.activeToplevel
        && Hypr.Hyprland.focusedWorkspace
        && Hypr.Hyprland.activeToplevel.workspace === Hypr.Hyprland.focusedWorkspace
    ) ? Hypr.Hyprland.activeToplevel : null

    Text {
        id: titleText
        //anchors.fill: parent
        verticalAlignment: Text.AlignVCenter

        text: activeOnCurrent
              ? activeOnCurrent.title
              : "Desktop"

        elide: Text.ElideRight
        color: "white"
        font.pixelSize: 14
    }
}

