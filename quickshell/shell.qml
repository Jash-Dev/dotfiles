import QtQuick
import Quickshell
import "./modules/bar"
import "./modules/appL/"

ShellRoot {
    id: root

    Loader {
        active: true
        sourceComponent: Bar{}
    }

    // APP LAUNCHER LOADER
    Loader {
        id: launcherLoader
        active: false
        sourceComponent: Appl{}
    }
}

