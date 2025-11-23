import QtQuick
import Quickshell
import Quickshell.Hyprland
import "./widgets"

PanelWindow {
    id: panel
    
    Style { id: style }

    anchors {
        bottom: true
        left: true
        right: true
    }

    implicitHeight: 48   // panel is taller than bar
    color: "#00000000"

    margins {
        bottom: 0
        left: 0
        right: 0
    }

    Rectangle {
        id: bar

        // IMPORTANT: do NOT fill the parent anymore
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }

        height: 40     // the bar height (you can change this)

        color: style.bar.background
        radius: style.bar.radius
        border.color: style.bar.borderColor
        border.width: style.bar.borderWidth

        clip: false   // allow diamonds etc. to pop out visually

        // Workspace indicator on the left
        Workspaces {
            id: workspacesRow
            anchors {
                left: parent.left
                verticalCenter: parent.verticalCenter
                leftMargin: padding
              }
        Activewindow {}
        }

        Clock {
            id: clock
            anchors {
                verticalCenter: parent.verticalCenter
                horizontalCenter: parent.horizontalCenter
            }
        }

        RightMod {
            anchors {
                right: parent.right
                verticalCenter: parent.verticalCenter
                verticalCenterOffset: 15
                rightMargin: 16
            }
        }
    }
}

