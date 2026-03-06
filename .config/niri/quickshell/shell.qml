import Quickshell
import Quickshell.Io
// import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts
import Niri

ShellRoot {
    readonly property color activeColor: "#7bf"
    readonly property color backgroundColor: "#333"

    readonly property int panelRadius: 12
    readonly property color panelBorderColor: "#888"
    readonly property real panelBorderWidth: 2
    readonly property real panelMargin: -Math.ceil(panelBorderWidth)

    Item {
        id: playerctl

        readonly property string cMEDIA_PLAYING: "▶️"
        readonly property string cMEDIA_PAUSED: "⏸️"
        readonly property string cMEDIA_STOPPED: "⏹️"

        property string status: "Stopped"
        property string status_emoji: cMEDIA_STOPPED;
        property string metadata: ""

        Process {
            id: _status
            command: ["playerctl", "-F", "status"]
            stdout: SplitParser {}
        }

        Process {
            id: _metadata
            command: ["playerctl", "-F", "metadata", "-f", "{{ artist }} - {{ title }}"]
            stdout: SplitParser {}
        }

        Component.onCompleted: {
            _status.stdout.read.connect(line => {
                status = line;
                if (line == "Playing") {
                    status_emoji = cMEDIA_PLAYING;
                } else if (line == "Paused") {
                    status_emoji = cMEDIA_PAUSED;
                } else if (line == "Stopped") {
                    status_emoji = cMEDIA_STOPPED;
                } else {
                    status_emoji = line;
                }
            })
            _metadata.stdout.read.connect(line => metadata = line)
            _status.running = true
            _metadata.running = true
        }
    }

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

                Row {
                    Text {
                        anchors.baseline: player_text.baseline
                        text: playerctl.status_emoji
                        color: activeColor
                        font.pixelSize: 18
                        rightPadding: 4
                    }
                    Text {
                        id: player_text
                        text: playerctl.metadata
                        color: activeColor
                        font.pixelSize: 14
                    }
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
