// RightMod.qml
import QtQuick
import Quickshell
import "./widgets"

Item {
    id: rightModules

    // width from content, height from parent (bar)
    width: row.implicitWidth
    height: parent ? parent.height : row.implicitHeight

    Row {
        id: row
        spacing: 12

        // make the Row fill the bar height
        anchors.fill: parent           // <-- change
        anchors.margins: 0             // keep it simple

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

        
    }
}

