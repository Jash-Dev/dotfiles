// RightMod.qml
import QtQuick
import Quickshell
import "./widgets"

Item {
    id: rightModules

    // Width from content, HEIGHT from parent (the bar)
    width: row.implicitWidth
    height: parent ? parent.height : row.implicitHeight

    Row {
        id: row
        spacing: 12

        anchors.verticalCenter: parent.verticalCenter

        Text {
            id: separator0
            text: "|"
            color: "white"
        }

        Mpris { id: mpris }

        Text {
            id: separator1
            text: "|"
            color: "white"
        }

        Volume { id: volume }

        Text {
            id: separator2
            text: "|"
            color: "white"
        }

        Connect { id: connect }

        Bluetooth { id: bluetooth }

        Text {
            id: separator3
            text: "|"
            color: "white"
        }

        Clock { id: clock }
    }
}

