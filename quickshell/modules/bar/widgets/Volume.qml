// Volume.qml (PipeWire-native version)
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

        Text {
            id: icon
            text: iconGlyph
            color: "white"
            font.pixelSize: 16

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    volumeCtl.exec([
                        "wpctl", "set-mute", "@DEFAULT_AUDIO_SINK@", muted ? "0" : "1"
                    ]);
                    muted = !muted;
                }
            }
        }

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
                    root.setLevelFromPos(mouse.x);
                    root.applyVolume();
                }
            }
        }
    }

    function setLevelFromPos(mouseX) {
        var localX = mouseX - sliderBox.x - track.x;
        var ratio = localX / track.width;
        var newLevel = Math.round(Math.max(0, Math.min(1, ratio)) * 100);
        level = newLevel;
        if (level === 0) muted = true;
    }

    // --- wpctl plumbing ---
    Process { id: volumeCtl }

    Process {
        id: volumeQuery
        stdout: StdioCollector {
            onStreamFinished: {
                root.updateFromWpctl(text);
            }
        }
    }

    // Query volume + mute via wpctl
    function pollVolume() {
        volumeQuery.exec(["wpctl", "get-volume", "@DEFAULT_AUDIO_SINK@"]);
    }

    // Parse output of:
    //   wpctl get-volume @DEFAULT_AUDIO_SINK@
    // Example:
    //   Volume: 0.54 [muted]
    function updateFromWpctl(out) {
        if (!out) return;

        var m = out.match(/Volume:\s*([\d.]+)/);
        if (m) {
            level = Math.round(parseFloat(m[1]) * 100);
        }

        muted = out.toLowerCase().includes("muted");
    }

    // Apply volume via wpctl (accepts 0.0–1.0)
    function applyVolume() {
        volumeCtl.exec([
            "wpctl", "set-volume",
            "@DEFAULT_AUDIO_SINK@",
            (level / 100.0).toString()
        ]);

        if (level > 0 && muted) {
            volumeCtl.exec(["wpctl", "set-mute", "@DEFAULT_AUDIO_SINK@", "0"]);
            muted = false;
        }
    }

    Timer {
        id: pollTimer
        interval: 100
        running: true
        repeat: true
        onTriggered: root.pollVolume()
    }

    Component.onCompleted: pollVolume()
}
