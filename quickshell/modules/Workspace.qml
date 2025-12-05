import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland

Item {
    id: root
    anchors.fill: parent

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 8
        spacing: 6

        Repeater {
            model: 5

            Rectangle {
                width: 20
                height: 20
                radius: 4

                property var ws: Hyprland.workspaces.values.find(w => w.id === index + 1)
                property bool isActive: Hyprland.focusedWorkspace?.id === (index + 1)

                color: isActive ? "#283347" : "transparent"
                border.color: ws ? "#7aa2f7" : "#444b6a"
                border.width: isActive ? 2 : 1

                Text {
                    anchors.centerIn: parent
                    text: index + 1
                    color: isActive ? "#0db9d7" : (ws ? "#7aa2f7" : "#444b6a")
                    font.pixelSize: 14
                    font.bold: true
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: Hyprland.dispatch("workspace " + (index + 1))
                }
            }
        }

        Item { Layout.fillHeight: true }
    }
}

