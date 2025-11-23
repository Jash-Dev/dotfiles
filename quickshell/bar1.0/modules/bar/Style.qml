
import QtQuick

QtObject {
    id: style

    // ---------- GLOBAL BAR STYLE ----------
    property QtObject bar: QtObject {
        property int height: 32
        property int radius: 0
        property int borderWidth: 3
        property color background: "#222222"
        property color borderColor: "#00333333"
        property color windowColor: "#00000000"
    }

    // ---------- WORKSPACES STYLE ----------
    property QtObject workspaces: QtObject {
        property int padding: 12
        property int spacing: 8
        property color inactiveColor: "#3a3a3a"
        property color activeColor: "#e0e0e0"
        property color textColor: "#1e1e1e"
    }

    // ---------- ACTIVE WINDOW STYLE ----------
    property QtObject activeWindow: QtObject {
        property int fontSize: 20
        property color textColor: "white"
        property string fontFamily: "JetBrainsMono Nerd Font"
    }

    // ---------- RIGHT MOD STYLE ----------
    property QtObject rightMod: QtObject {
        property int rightMargin: 16
        property int verticalOffset: 5
        property int iconSize: 16
    
    }
}

