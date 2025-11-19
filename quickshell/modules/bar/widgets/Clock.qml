import QtQuick
import Quickshell

Row {
    id: root
    spacing: 8

    function updateTime() {
        const now = new Date();
        timeText.text =
            now.getHours().toString().padStart(2, "0") + ":" +
            now.getMinutes().toString().padStart(2, "0");
    }

    Timer {
        id: tick
        interval: 1000
        running: true
        repeat: true
        onTriggered: updateTime()
    }

    Text {
        id: timeText
        text: "--:--"
        color: "white"
        font.pixelSize: 16
    }

    Component.onCompleted: tick.triggered()
}

