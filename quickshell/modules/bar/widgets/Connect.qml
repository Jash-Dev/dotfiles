// Connect.qml
import QtQuick
import Quickshell
import Quickshell.Io

Row {
    id: root

    width: content.implicitWidth
    height: content.implicitHeight

    // ---- Network state ----
    // "offline", "wired", "wifi"
    property string mode: "offline"
    property string ssid: ""

    // ---- Bluetooth state ----
    property bool btOn: false
    property bool btConnected: false
    property bool btVisible: btOn || btConnected

    // ---- Derived display bits ----
    property string netIcon: {
        if (mode === "wired") return "";   // ethernet
        if (mode === "wifi")  return "";   // wifi
        return "";                          // offline
    }

    property string netLabel: {
        if (mode === "wired") return "Wired";
        if (mode === "wifi")  return ssid !== "" ? ssid : "Wi-Fi";
        return "Offline";
    }

    property string btIcon: "󰂯"

    Row {
        id: content
        spacing: 8
        anchors.verticalCenter: parent.verticalCenter

        Text {
            text: netIcon
            color: "white"
            font.pixelSize: 16
        }

        Text {
            text: netLabel
            color: "white"
            font.pixelSize: 16
            elide: Text.ElideRight
        }

        Text {
            visible: btVisible
            text: btIcon
            color: btConnected ? "white" : "#aaaaaa"
            font.pixelSize: 16
        }
    }

    // ---------- Wi-Fi via nmcli ----------

    Process {
        id: nmcliProc

        stdout: StdioCollector {
            onStreamFinished: {
                root.updateFromNmcli(text);
            }
        }
    }

    function pollNmcli() {
        nmcliProc.exec([
            "nmcli",
            "-t",
            "-f",
            "DEVICE,TYPE,STATE,CONNECTION",
            "device"
        ]);
    }

    function updateFromNmcli(output) {
        var newMode = "offline";
        var newSsid = "";

        if (!output)
            return;

        var lines = output.trim().split("\n");
        for (var i = 0; i < lines.length; i++) {
            var line = lines[i];
            if (line === "")
                continue;

            // DEVICE:TYPE:STATE:CONNECTION
            var parts = line.split(":");
            if (parts.length < 4)
                continue;

            var type  = parts[1];
            var state = parts[2];
            var conn  = parts[3];

            if (type === "ethernet" && state === "connected") {
                newMode = "wired";
                newSsid = "";
                break; // prefer wired, bail early
            }

            if (type === "wifi" && state === "connected") {
                if (newMode !== "wired") {
                    newMode = "wifi";
                    newSsid = conn;
                }
            }
        }

        mode = newMode;
        ssid = newSsid;
    }
    
    
    // ---------- Poll timers ----------

    Timer {
        id: pollTimer
        interval: 5000
        running: true
        repeat: true
        onTriggered: {
            pollNmcli();
            
        }
    }

    Component.onCompleted: {
        pollNmcli();
            }
}

