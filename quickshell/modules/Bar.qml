import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Io   // <-- needed for Process / StdioCollector
import "."


PanelWindow {
    id: bar
    anchors.left: true
    anchors.top: true
    anchors.bottom: true


    Style {
	    id:style}
    // master scale knob for the whole bar
    property real uiScale: 1.25   // tweak 1.2–1.5 for comfort

    implicitWidth: 32 * uiScale
    color: style.bg

    // ======================
    // STATE
    // ======================
    property string timeString: "--:--"
    property bool pomodoroActive: false
    property bool isMuted: false
    property bool isOnline: true

    // ---- TASK STATE ----
    property int taskCount: 0
    // Replace this with your real CLI:
    // It must output ONLY a number (e.g. "5\n")
    property string taskCountCommand: "taskcli --count"

    function updateTime() {
        const now = new Date();
        const hh = now.getHours().toString().padStart(2, "0");
        const mm = now.getMinutes().toString().padStart(2, "0");
        timeString = hh + "\n" + mm;
    }

    // ======================
    // CLOCK TIMER
    // ======================
    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: bar.updateTime()
    }

    // ======================
    // TASK COUNT REFRESH
    // ======================
    Process {
        id: taskCountProc
        // run via shell so you can put anything in taskCountCommand
        command: [ "sh", "-c", bar.taskCountCommand ]

        stdout: StdioCollector {
            onStreamFinished: {
                // this.text is full stdout
                const raw = this.text.trim();
                const n = parseInt(raw, 10);
                if (!isNaN(n)) {
                    bar.taskCount = n;
                } else {
                    bar.taskCount = 0;
                }
            }
        }
    }

    // run once at startup
    Component.onCompleted: {
        updateTime();
        taskCountProc.running = true;
    }

    // refresh every 60s
    Timer {
        interval: 60000
        running: true
        repeat: true
        onTriggered: taskCountProc.running = true;
    }

    ColumnLayout {
        id: layout
        anchors.fill: parent
        anchors.margins: 4 * uiScale
        spacing: 6 * uiScale

        // ======================
        // TOP: WORKSPACES
        // ======================
        Repeater {
            model: 5

            Rectangle {
                width: 20 * uiScale
                height: 20 * uiScale
                radius: 4 * uiScale

                property var ws: Hyprland.workspaces.values.find(w => w.id === index + 1)
                property bool isActive: Hyprland.focusedWorkspace?.id === (index + 1)

		color: isActive ? "#283347" : "transparent"
                border.color: ws ? "#7aa2f7" : "#444b6a"
                border.width: isActive ? 2 : 1

                Text {
                    anchors.centerIn: parent
                    text: index + 1
                    color: isActive ? "#0db9d7" : (ws ? "#7aa2f7" : "#444b6a")
                    font.pixelSize: 11 * uiScale
                    font.bold: true
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: Hyprland.dispatch("workspace " + (index + 1))
                }
            }
        }

        Item { Layout.fillHeight: true }

        // ======================
        // CENTER: POMODORO INDICATOR
        // ======================
        Rectangle {
            Layout.alignment: Qt.AlignHCenter
            width: 16 * uiScale
            height: 16 * uiScale
            radius: 8 * uiScale
            color: pomodoroActive ? "#9ece6a" : "#2f3348"

            Text {
                anchors.centerIn: parent
                text: pomodoroActive ? "P" : "●"
                color: pomodoroActive ? "#1a1b26" : "#9ece6a"
                font.pixelSize: 9 * uiScale
                font.bold: pomodoroActive
            }
        }

        // ======================
        // CENTER: CLOCK
        // ======================
        Rectangle {
            Layout.alignment: Qt.AlignHCenter
            width: 24 * uiScale
            height: 24 * uiScale
            radius: 5 * uiScale
            color: "#222437"

            Text {
                anchors.centerIn: parent
                text: bar.timeString
                color: "#a9b1d6"
                font.pixelSize: 10 * uiScale
                font.bold: true
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
        }

        // ======================
        // CENTER: TODO BUTTON (shows T-<count>)
        // ======================
        Rectangle {
            Layout.alignment: Qt.AlignHCenter
            width: 24 * uiScale
            height: 18 * uiScale
            radius: 4 * uiScale
            color: "#1f2336"
            border.color: "#565f89"
            border.width: 1

            Text {
                anchors.centerIn: parent
                // Show "T-5", "T-0", etc.
                text: "T-" + bar.taskCount
                color: "#c0caf5"
                font.pixelSize: 9 * uiScale
                font.bold: true
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    // OPTIONAL: open a terminal with the full todo list
                    // e.g. Quickshell.execDetached(["alacritty", "-e", "taskcli"]);
                    console.log("TODO button clicked (launch taskcli here)");
                }
            }
        }

        Item { Layout.fillHeight: true }

        // ======================
        // BOTTOM: CONNECTIVITY + VOLUME + HEALTH BUTTON
        // ======================
        ColumnLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: 4 * uiScale

            // ONLINE / OFFLINE INDICATOR (CLICKABLE)
            Rectangle {
                width: 22 * uiScale
                height: 22 * uiScale
                radius: 5 * uiScale
                color: isOnline ? "#1f2336" : "#301b1f"
                border.color: isOnline ? "#7aa2f7" : "#f7768e"
                border.width: 1

                Text {
                    anchors.centerIn: parent
                    text: isOnline ? "直" : "睊"
                    color: isOnline ? "#7aa2f7" : "#f7768e"
                    font.pixelSize: 12 * uiScale
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        console.log("Connectivity widget trigger (network health, up/down, etc.)");
                    }
                }
            }

            // VOLUME INDICATOR (NON-CLICKABLE)
            Text {
                Layout.alignment: Qt.AlignHCenter
                text: isMuted ? "" : ""
                color: "#c0caf5"
                font.pixelSize: 13 * uiScale
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            // HEALTH BUTTON
            Rectangle {
                width: 22 * uiScale
                height: 20 * uiScale
                radius: 6 * uiScale
                color: "#24283b"
                border.color: "#9ece6a"
                border.width: 1

                Text {
                    anchors.centerIn: parent
                    text: "♥"
                    color: "#9ece6a"
                    font.pixelSize: 11 * uiScale
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        console.log("Health widget trigger (open big panel later)");
                    }
                }
            }
        }
    }
}

