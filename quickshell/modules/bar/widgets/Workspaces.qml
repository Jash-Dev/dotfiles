import Quickshell
import Quickshell.Hyprland
import QtQuick

Row {
    id: root
    spacing: 8

    // you can expose padding if you want:
    property int padding: 16

    Repeater {
        model: Hyprland.workspaces

        delegate: Rectangle {
            required property var modelData

            // hide scratchpad / special workspaces
            visible: !modelData.name.startsWith("special")

            width: 32
            height: 24
            radius: 4
            color: modelData.active ? "#4a9eff" : "#234232"
            border.color: "#555555"
            border.width: 2

            Text {
                anchors.centerIn: parent
                text: modelData.id.toString()
                color: "white"
                font.pixelSize: 12
            }

            MouseArea {
                anchors.fill: parent
                onClicked: Hyprland.dispatch("workspace " + modelData.id)
            }
        }
    }
}
