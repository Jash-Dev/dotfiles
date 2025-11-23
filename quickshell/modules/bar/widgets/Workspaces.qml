import Quickshell
import Quickshell.Hyprland
import QtQuick

Row {
    id: root
    spacing: 8

    property int padding: 16

    Repeater {
        model: Hyprland.workspaces

        delegate: Rectangle {
            id: wsRect
            required property var modelData

            property bool isActive: modelData.active

            // Only draw the active one
            visible: isActive

            width: 24
            height: 24

            // Diamond shape
            rotation: 45
            radius: 2

            color: "#884a9eff"
            border.color: "#88ffffff"
            border.width: 2
            antialiasing: true
            z: 10

            // pop it out of the bar
            y: -10

            // NUMBER that "springs" out
            Text {
                id: label
                anchors.centerIn: parent
                text: modelData.id === 10 ? "*" : modelData.id.toString()
                color: "white"
                font.pixelSize: 40

                // keep text upright
                rotation: -45
                z: 999

                // base position (slightly inside the diamond)
                property real baseY: -4
                y: baseY

                style: Text.Outline
                styleColor: "#000000"

                // start a bit smaller when "inactive"
                scale: 0.8
            }

            // States for the label to control the "spring"
            states: [
                State {
                    name: "inactive"
                    when: !isActive
                    PropertyChanges {
                        target: label
                        scale: 0.8
                        y: label.baseY + 2   // a bit inside
                    }
                },
                State {
                    name: "active"
                    when: isActive
                    PropertyChanges {
                        target: label
                        scale: 1.0
                        y: label.baseY - 4   // a bit above
                    }
                }
            ]

            // Spring / bounce between inactive -> active
            transitions: [
                Transition {
                    from: "inactive"
                    to: "active"

                    SequentialAnimation {
                        // first: overshoot (big pop)
                        NumberAnimation {
                            targets: [ label ]
                            properties: "scale,y"
                            duration: 120
                            easing.type: Easing.OutBack
                            to: 1.25   // scale overshoot
                        }
                        // then: settle back to final active state
                        NumberAnimation {
                            targets: [ label ]
                            properties: "scale,y"
                            duration: 80
                            easing.type: Easing.InOutQuad
                            // "to" not needed: it animates into the active state's values
                        }
                    }
                }
            ]

            MouseArea {
                anchors.fill: parent
                onClicked: Hyprland.dispatch("workspace " + modelData.id)
            }
        }
    }
}

