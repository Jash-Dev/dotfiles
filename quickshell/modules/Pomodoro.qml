// modules/Pomodoro.qml
import Quickshell
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell.Wayland
import Quickshell.Io

Scope {
    id: root

    // === external controls ===
    // shell.qml just does: Pomodoro {}
    // Hypr keybinds talk to this via `qs ipc call pomodoro ...`

    // On/off
    property bool active: false

    // Settings window visibility
    property bool settingsVisible: false

    // Configurable durations (minutes)
    property int workMinutes: 25
    property int breakMinutes: 5

    // Runtime state
    property bool onBreak: false
    property int remainingSeconds: workMinutes * 60
    property int sessionsCompleted: 0

    // ---------- core functions ----------
    function formatTime(sec) {
        var m = Math.floor(sec / 60)
        var s = sec % 60
        return (m < 10 ? "0" : "") + m + ":" + (s < 10 ? "0" : "") + s
    }

    function resetForCurrentMode() {
        remainingSeconds = (onBreak ? breakMinutes : workMinutes) * 60
    }

    // Default 25/5 start
    function startDefault() {
        workMinutes = 25
        breakMinutes = 5
        onBreak = false
        resetForCurrentMode()
        active = true
    }

    function stop() {
        active = false
    }

    // Used by Super + P and bar icon
    function toggleDefault() {
        if (active)
            stop()
        else
            startDefault()
    }

    function openSettings() {
        settingsVisible = true
    }

    // ---------- IPC: called from qs CLI ----------
    IpcHandler {
        id: pomodoroIpc
        target: "pomodoro"

        // Super + P
        function toggleDefault(): void {
            root.toggleDefault()
        }

        // Super + Shift + P
        function openSettings(): void {
            root.openSettings()
        }

        function stop(): void {
            root.stop()
        }
    }

    // ---------- Timer ----------
    Timer {
        id: tick
        interval: 1000
        running: root.active
        repeat: true

        onTriggered: {
            if (root.remainingSeconds > 0) {
                root.remainingSeconds--
            } else {
                if (!root.onBreak)
                    root.sessionsCompleted++

                root.onBreak = !root.onBreak
                root.resetForCurrentMode()
            }
        }
    }

    // ---------- HUD overlay (bottom-right, click-through) ----------
    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: overlay

            property var modelData
            screen: modelData

            anchors {
                right: true
                bottom: true
            }

            margins {
                right: 50
                bottom: 50
            }

            implicitWidth: content.implicitWidth
            implicitHeight: content.implicitHeight

            color: "transparent"
            visible: root.active

            mask: Region {}
            WlrLayershell.layer: WlrLayer.Overlay

            ColumnLayout {
                id: content
                spacing: 4

                Text {
                    text: root.onBreak ? "Break Time" : "Focus Time"
                    color: "#50ffffff"
                    font.pointSize: 18
                    font.bold: true
                    Layout.alignment: Qt.AlignRight
                }

                Text {
                    text: root.formatTime(root.remainingSeconds)
                    color: "#80ffffff"
                    font.pointSize: 32
                    font.bold: true
                    Layout.alignment: Qt.AlignRight
                }

                Text {
                    text: "Sessions: " + root.sessionsCompleted
                    color: "#40ffffff"
                    font.pointSize: 10
                    Layout.alignment: Qt.AlignRight
                }
            }
        }
    }

    // ---------- Settings popup (QS widget) ----------
    PanelWindow {
        id: settingsWin

        visible: root.settingsVisible
        screen: Quickshell.primaryScreen
        WlrLayershell.layer: WlrLayer.Top

        //anchors {
        //    horizontalCenter: true
        //    verticalCenter: true
        //}

        color: "#dd000000"

        implicitWidth: content.implicitWidth + 24
        implicitHeight: content.implicitHeight + 24

        ColumnLayout {
            id: content
            anchors.fill: parent
            anchors.margins: 12
            spacing: 8

            Text {
                text: "Pomodoro Settings"
                color: "#ffffff"
                font.pointSize: 12
                font.bold: true
            }

            RowLayout {
                spacing: 6
                Text {
                    text: "Work (min):"
                    color: "#ffffff"
                    font.pointSize: 10
                }
                SpinBox {
                    id: workSpin
                    from: 5
                    to: 120
                    value: root.workMinutes
                    onValueChanged: root.workMinutes = value
                }
            }

            RowLayout {
                spacing: 6
                Text {
                    text: "Break (min):"
                    color: "#ffffff"
                    font.pointSize: 10
                }
                SpinBox {
                    id: breakSpin
                    from: 1
                    to: 60
                    value: root.breakMinutes
                    onValueChanged: root.breakMinutes = value
                }
            }

            RowLayout {
                spacing: 8

                Button {
                    text: "Start with these"
                    onClicked: {
                        root.onBreak = false
                        root.resetForCurrentMode()
                        root.active = true
                    }
                }

                Button {
                    text: root.active ? "Stop" : "Close"
                    onClicked: {
                        if (root.active)
                            root.stop()
                        root.settingsVisible = false
                    }
                }
            }
        }
    }
}

