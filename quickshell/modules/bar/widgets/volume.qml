// Volume.qml
import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root

    // --- geometry ---
    property int sliderWidth: 80
    property int sliderHeight: 6

    width: icon.implicitWidth + 8 + sliderWidth
    height: Math.max(icon.implicitHeight, sliderHeight + 8)

    // --- state ---
    property int level: 50          // 0–100
    property bool muted: false
    property bool dragging: false

    readonly property string iconGlyph: {
        if (muted || level === 0) return "";
        if (level < 30) return "";
        return "";
    }

    // --- layout ---
    Row {
        id: content
        spacing: 8
        anchors.verticalCenter: parent.verticalCenter

        // ICON
        Text {
            id: icon
            text: iconGlyph
            color: "white"
            font.pixelSize: 16

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    // toggle mute
                    volumeCtl.exec([
                        "pactl", "set-sink-mute", "@DEFAULT_SINK@", muted ? "0" : "1"
                    ]);
                    muted = !muted;
                }
            }
        }

        // SLIDER
        Item {
            id: sliderBox
            width: root.sliderWidth
            height: root.sliderHeight + 8
            anchors.verticalCenter: parent.verticalCenter

            Rectangle {
                id: track
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                width: root.sliderWidth
                height: root.sliderHeight
                radius: root.sliderHeight / 2
                color: "#444444"
            }

            Rectangle {
                id: fill
                anchors.verticalCenter: track.verticalCenter
                x: track.x
                width: (level / 100.0) * track.width
                height: track.height
                radius: track.radius
                color: "#aaaaaa"
            }

            Rectangle {
                id: thumb
                anchors.verticalCenter: track.verticalCenter
                width: 10
                height: 10
                radius: 5
                x: track.x + (level / 100.0) * track.width - width / 2
                color: "#ffffff"
            }

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                drag.target: thumb
                drag.axis: Drag.XAxis
                drag.minimumX: track.x - thumb.width / 2
                drag.maximumX: track.x + track.width - thumb.width / 2

                onPressed: (mouse) => {
                    dragging = true;
                    root.setLevelFromPos(mouse.x);
                }

                onPositionChanged: (mouse) => {
                    if (dragging) {
                        root.setLevelFromPos(mouse.x);
                    }
                }

                onReleased: {
                    dragging = false;
                    root.applyVolume();
                }

                onClicked: (mouse) => {
                    // simple click without drag
                    root.setLevelFromPos(mouse.x);
                    root.applyVolume();
                }
            }
        }
    }

    // --- helper to convert mouse.x → level ---
    function setLevelFromPos(mouseX) {
        var localX = mouseX - sliderBox.x - track.x;
        var ratio = localX / track.width;
        var newLevel = Math.round(Math.max(0, Math.min(1, ratio)) * 100);
        level = newLevel;
        if (level === 0) muted = true;
    }

    // --- pactl plumbing ---
    Process {
        id: volumeCtl
    }

    Process {
        id: volumeQuery

        stdout: StdioCollector {
            onStreamFinished: {
                root.updateFromPactl(text);
            }
        }
    }

    function pollVolume() {
        // Volume
        volumeQuery.exec([
            "pactl", "get-sink-volume", "@DEFAULT_SINK@"
        ]);
        // Mute state
        volumeQuery.exec([
            "pactl", "get-sink-mute", "@DEFAULT_SINK@"
        ]);
    }

    function updateFromPactl(output) {
        if (!output)
            return;

        var lines = output.trim().split("\n");
        for (var i = 0; i < lines.length; ++i) {
            var line = lines[i].trim();

            if (line.startsWith("Volume:")) {
                // e.g. "Volume: front-left: 32768 /  50% / ..."
                var match = line.match(/([0-9]+)%/);
                if (match && match.length > 1) {
                    level = parseInt(match[1]);
                }
            }

            if (line.startsWith("Mute:")) {
                muted = line.toLowerCase().indexOf("yes") !== -1;
            }
        }
    }

    function applyVolume() {
        // apply current level to system
        volumeCtl.exec([
            "pactl", "set-sink-volume",
            "@DEFAULT_SINK@", level + "%"
        ]);
        if (level > 0 && muted) {
            volumeCtl.exec([
                "pactl", "set-sink-mute", "@DEFAULT_SINK@", "0"
            ]);
            muted = false;
        }
    }

    Timer {
        id: pollTimer
        interval: 3000
        running: true
        repeat: true
        onTriggered: root.pollVolume()
    }

    Component.onCompleted: {
        pollVolume();
    }
}

