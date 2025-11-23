// Mpris.qml
import QtQuick
import Quickshell
import Quickshell.Services.Mpris

Item {
    id: root
    visible: player !== null && label !== ""

    // Fixed width box so it can't run into Volume
    property int maxWidth: 260

    width: maxWidth
    height: content.implicitHeight
    clip: true    // <-- do not draw outside this box

    property var player: ( 
      Mpris.players.values.length > 0
      ? Mpris.players.values[0]
      : null
      )

    property string title: player ? (player.trackTitle || "") : ""
    property string artist: player ? (player.trackArtist || "") : ""
    property bool playing: player ? player.isPlaying : false
    property string label: title + artist

    Row {
        id: content
        spacing: 4
        anchors {
            left: parent.left
            right: parent.right
            verticalCenter: parent.verticalCenter
            verticalCenterOffset: -5
        }

        Text {
            id: icon
            text: "󰝚 "
            color: "white"
            font.pixelSize: textItem.font.pixelSize + 10
            anchors{ 
              verticalCenter: titleBox.verticalCenter
              verticalCenterOffset: 5}

        }

        Item {
           id: titleBox
           width: root.maxWidth - icon.implicitWidth - content.spacing
           height: textItem.implicitHeight
           anchors.verticalCenter: parent.verticalCenter
           clip: true
           
           property real offset: 0
           property bool overflowing: textItem.paintedWidth > width

           Text {
             id: textItem
             x: -titleBox.offset
             text: label
             color: "white"
             font.pixelSize: 16
             elide: Text.ElideRight
           }

           Timer {
                interval: 40
                running: titleBox.overflowing
                repeat: true
                onTriggered: {
                    if (!titleBox.overflowing) {
                        titleBox.offset = 0;
                        return;
                    }
                    var maxOffset = textItem.paintedWidth - titleBox.width;
                    if (titleBox.offset >= maxOffset) {
                        titleBox.offset = 0;
                    } else {
                        titleBox.offset += 1; 
                    }
                }
           }
        }
    }
}
