import QtQuick
import Quickshell
import Quickshell.Hyprland
import "./widgets"

PanelWindow {
    id: panel

    anchors {
        bottom: true
        left: true
        right: true
    }

    implicitHeight: 40

    color: "#00000000"  // transparent window

    margins {
        bottom: 00000000
        left: 00000000
        right: 00000000
    }

    Rectangle {
        id: bar
        anchors.fill: parent
        color: "#1a1a1a"
        radius: 6 
        border.color: "#333333"
        border.width: 3
    //Workspace indicator on the left 
        Workspaces{
          id: workspacesRow
          
          anchors {
              left: parent.left
              verticalCenter: parent.verticalCenter
              leftMargin: padding
          }
        }
      //ActiveWindow in the 
      Activewindow{
        id: activewindow
        anchors {
          verticalCenter: parent.verticalCenter
          horizontalCenter: parent.horizontalCenter
        }
      }
       //Connectivity to the left of the Clock
       //Time display on the right
       RightMod{

         anchors {
           right: parent.right
           verticalCenter: parent.verticalCenter
           verticalCenterOffset: 5
           rightMargin: 16
         }

     }
      
                }
      }
    

