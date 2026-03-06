import Quickshell
// import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts
import Niri

ShellRoot {
    property color activeColor: "#7bf"
    property color backgroundColor: "#333"

    property int panelRadius: 12
    property color panelBorderColor: "#888"
    property real panelBorderWidth: 2
    property real panelMargin: -Math.ceil(panelBorderWidth)

    Niri {
        id: niri
        Component.onCompleted: connect()

        onConnected: console.info("Connected to niri")
        onErrorOccurred: err => console.error("Niri error:", err)
    }

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    PanelWindow {
        id: bar
        anchors { top: true; left: true; right: true; }
        implicitHeight: 30
        color: "transparent"

        Rectangle {
            anchors.fill: left_panel
            bottomRightRadius: panelRadius
            color: backgroundColor
            border {
                width: panelBorderWidth
                color: panelBorderColor
            }
        }
        RowLayout {
            id: left_panel

            anchors {
                top: parent.top
                left: parent.left
                bottom: parent.bottom
                topMargin: panelMargin
                leftMargin: panelMargin
            }

            Row {
                leftPadding: 8
                rightPadding: 4

                Repeater {
                    model: niri.workspaces

                    Text {
                        text: model.index

                        font.pixelSize: 16
                        font.weight: model.isActive ? 800 : 300
                        color: activeColor
                        leftPadding: 8
                        rightPadding: 8

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: niri.focusWorkspaceById(model.id)
                        }
                    }
                }
            }

            // Rectangle {
            //     height: parent.height
            //     width: 1
            //     color: "#aaa"
            // }

            // Text {
            //     text: niri.focusedWindow?.appId ?? ""
            //     color: activeColor
            //     font.pixelSize: 16
            //     rightPadding: 8
            // }
        }

        Rectangle {
            anchors.fill: right_panel
            bottomLeftRadius: panelRadius
            color: backgroundColor
            border {
                width: panelBorderWidth
                color: panelBorderColor
            }
        }
        RowLayout {
            id: right_panel

            anchors {
                top: parent.top
                right: parent.right
                bottom: parent.bottom
                topMargin: panelMargin
                rightMargin: panelMargin
            }

            Row {
                leftPadding: 12
                rightPadding: 12
                spacing: 12

                Text {
                    text: "fred"
                    color: activeColor
                    font.pixelSize: 16
                }

                Rectangle {
                    height: parent.height
                    width: 1
                    color: "#aaa"
                }

                Text {
                    text: Qt.formatDateTime(clock.date, "hh:mm - ddd, d MMM")
                    color: activeColor
                    font.pixelSize: 16
                }
            }
        }
    }
}
