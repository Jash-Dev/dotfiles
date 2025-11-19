// Bluetooth.qml
import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root

    width: content.implicitWidth
    height: content.implicitHeight

    // ---- Bluetooth state ----
    property bool btOn: false
    property bool btConnected: false
    property string deviceName: ""

    // ---- Derived display bits ----
    // Nerd font Bluetooth icon; adjust if you prefer a different glyph
    property string btIcon: "󰂯"

    property string btLabel: {
        if (!btOn)          return "Bluetooth Off";
        if (btConnected) {
            if (deviceName !== "")
                return deviceName;
            return "Connected";
        }
        return "Bluetooth";
    }

    Row {
        id: content
        spacing: 8
        anchors.verticalCenter: parent.verticalCenter

        Text {
            text: btIcon
            color: btConnected ? "white" : "#aaaaaa"
            font.pixelSize: 16
        }

        Text {
            text: btLabel
            color: "white"
            font.pixelSize: 16
            elide: Text.ElideRight
        }
    }

    // ---------- Bluetooth via bluetoothctl ----------

    // 1) Controller status: Powered on/off
    Process {
        id: btShowProc

        stdout: StdioCollector {
            onStreamFinished: {
                root.updateFromShow(text);
            }
        }
    }

    // 2) Connected devices: names + MACs
    Process {
        id: btDevicesProc

        stdout: StdioCollector {
            onStreamFinished: {
                root.updateFromDevices(text);
            }
        }
    }

    function pollBluetooth() {
        // "bluetoothctl show" → controller status
        btShowProc.exec([
            "bluetoothctl",
            "show"
        ]);

        // "bluetoothctl devices Connected" → any connected devices?
        btDevicesProc.exec([
            "bluetoothctl",
            "devices",
            "Connected"
        ]);
    }

    function updateFromShow(output) {
        if (!output) {
            btOn = false;
            return;
        }

        // Look for line: "Powered: yes" or "Powered: no"
        var lines = output.trim().split("\n");
        var powered = false;

        for (var i = 0; i < lines.length; i++) {
            var line = lines[i].trim();
            if (line.startsWith("Powered:")) {
                // e.g. "Powered: yes"
                var parts = line.split(/\s+/);
                if (parts.length >= 2 && parts[1] === "yes") {
                    powered = true;
                }
                break;
            }
        }

        btOn = powered;
    }

    function updateFromDevices(output) {
        // "bluetoothctl devices Connected" format:
        // Device XX:XX:XX:XX:XX:XX Some Name
        btConnected = false;
        deviceName = "";

        if (!output)
            return;

        var lines = output.trim().split("\n");
        for (var i = 0; i < lines.length; i++) {
            var line = lines[i].trim();
            if (line === "")
                continue;

            // Take the first connected device we see
            if (line.startsWith("Device")) {
                // Split on spaces; first 2 tokens are "Device" and MAC
                var parts = line.split(/\s+/);
                if (parts.length >= 3) {
                    btConnected = true;
                    // Join everything after MAC as the device name
                    deviceName = parts.slice(2).join(" ");
                    break;
                }
            }
        }
    }

    // ---------- Poll timer ----------

    Timer {
        id: pollTimer
        interval: 5000
        running: true
        repeat: true
        onTriggered: root.pollBluetooth()
    }

    Component.onCompleted: {
        pollBluetooth();
    }
}

