import QtQuick
import QtQuick.Controls
import Quickshell

FloatingWindow {
    id: launcher
    title: "Launcher"   // optional
    minimumSize: Qt.size(700, 150)
    maximumSize: Qt.size(700, 600)

    Column {
        id: content
        anchors.fill: parent
        anchors.margins: 12
        spacing: 10

        TextField {
            id: search
            placeholderText: "Search apps…"
            focus: true
        }

        Label {
            text: "Launcher loaded correctly."
        }
    }
}

