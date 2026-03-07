import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire
import Quickshell.Services.Mpris
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

    Process {
        id: scriptrunner

        stdout: StdioCollector {}
        stderr: StdioCollector {
            onStreamFinished: {
                if (text !== "") {
                    console.debug(text.trim());
                }
            }
        }
    }

    readonly property string cMEDIA_PLAYING: "▶️"
    readonly property string cMEDIA_PAUSED: "⏸️"
    readonly property string cMEDIA_STOPPED: "⏹️"

    Item {
        id: pipewire

        readonly property string cSPEAKER_MUTED: "🔇";
        readonly property string cSPEAKER_LOW: "🔈";
        readonly property string cSPEAKER_MED: "🔉";
        readonly property string cSPEAKER_HIGH: "🔊";

        readonly property PwNode node: Pipewire.defaultAudioSink

        PwObjectTracker {
            objects: [pipewire.node]
        }

        property string prettyVolume: {
            const audio = node?.audio;
            if (typeof audio !== "object") {
                return "unknown";
            }
            if (audio.muted) {
                return `${cSPEAKER_MUTED} mute`;
            }
            const volume = audio.volume * 100;
            const voltxt = volume.toFixed(0);
            if (volume < 1) {
                return `${cSPEAKER_LOW} ${voltxt}%`;
            } else {
                return `${cSPEAKER_HIGH} ${voltxt}%`;
            }
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
                        text: index

                        font.pixelSize: 16
                        font.weight: isActive ? 800 : 300
                        color: activeColor
                        leftPadding: 8
                        rightPadding: 8

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: niri.focusWorkspaceById(id)
                        }
                    }
                }
            }
        }

        Rectangle {
            anchors.fill: middle_panel
            bottomLeftRadius: panelRadius
            bottomRightRadius: panelRadius
            color: backgroundColor
            border {
                width: panelBorderWidth
                color: panelBorderColor
            }
        }
        RowLayout {
            id: middle_panel

            anchors {
                top: parent.top
                horizontalCenter: parent.horizontalCenter
                bottom: parent.bottom
                topMargin: panelMargin
                rightMargin: panelMargin
            }

            Row {
                leftPadding: 12
                rightPadding: 12
                spacing: 8

                Repeater {
                    model: Mpris.players.values

                    Row {
                        spacing: 8

                        Rectangle {
                            height: parent.height
                            width: 1
                            color: "#aaa"
                            visible: index > 0
                        }

                        Text {
                            anchors.baseline: next.baseline
                            text: {
                                switch (playbackState) {
                                    case MprisPlaybackState.Playing:
                                        return cMEDIA_PLAYING;
                                    case MprisPlaybackState.Paused:
                                        return cMEDIA_PAUSED;
                                    case MprisPlaybackState.Stopped:
                                        return cMEDIA_STOPPED;
                                }
                                return "";
                            }
                            color: activeColor
                            font.pixelSize: 16

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: togglePlaying()
                            }
                        }

                        Text {
                            leftPadding: -6
                            id: next
                            text: `${trackArtist} - ${trackTitle}`
                            color: activeColor
                            font.pixelSize: 16
                            width: 300
                            elide: Text.ElideRight
                        }
                    }
                }
            }
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
                    text: pipewire.prettyVolume
                    color: activeColor
                    font.pixelSize: 16
                }

                Rectangle {
                    height: parent.height
                    width: 1
                    color: "#aaa"
                }

                Text {
                    id: datetime
                    text: Qt.formatDateTime(clock.date, "hh:mm - ddd, d MMM")
                    color: activeColor
                    font.pixelSize: 16
                }
            }
        }
    }
}
