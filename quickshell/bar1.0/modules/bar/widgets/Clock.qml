import QtQuick
import Quickshell
import "./bits"

Item {
    id: root

    implicitWidth: timeText.implicitWidth + 16
    implicitHeight: timeText.implicitHeight + 8

    property bool popupVisible: false

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

    // ==========================================
    //  POPUP WINDOW (NO TILING DEFORMATION)
    // ==========================================
   PanelWindow {
    id: popup

    exclusionMode: ExclusionMode.Ignore
    visible: height > 0 || root.popupVisible

    anchors {
        bottom: true
    }

    margins {
        bottom: 40
    }

    property int fullHeight: 480
    implicitWidth: 640
    height: root.popupVisible ? fullHeight : 0

    color: "#00000000"

    Behavior on height {
        NumberAnimation {
            duration: 200
            easing.type: Easing.OutCubic
        }
    }

    // THIS Rectangle is the "bubble" that visually grows
    Rectangle {
        anchors.fill: parent
        radius: 0              // flat bottom, grows out of bar
        color: "#222222"
        // border.color: "#444444"
        // border.width: 1
        clip: true

        // Calendar content lives inside
        Calendar {
            anchors.fill: parent
            anchors.margins: 10
        }
    }
}
    // ==============================
    //  CLOCK IN THE BAR
    // ==============================
    Rectangle {
        id: timeButton

        width: timeText.implicitWidth + 12
        height: timeText.implicitHeight + 6

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: -4

        radius: 4
        color: root.popupVisible ? "#444444" : "transparent"

        Text {
            id: timeText
            anchors.centerIn: parent
            text: "--:--"
            color: "white"
            font.pixelSize: 20
        }

        MouseArea {
            anchors.fill: parent
            onClicked: root.popupVisible = !root.popupVisible
        }
    }

    Component.onCompleted: tick.triggered()
}

