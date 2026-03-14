//@ pragma IconTheme breeze-dark

import Quickshell
import Quickshell.Services.Pipewire
import Quickshell.Services.Mpris
import QtQuick
import QtQuick.Layouts
import Quickshell.Widgets
import Niri

// https://develop.kde.org/frameworks/breeze-icons/

ShellRoot {
    readonly property color activeColor: "#7bf"
    readonly property color backgroundColor: "#333"

    readonly property int panelRadius: 12
    readonly property color panelBorderColor: "#888"
    readonly property real panelBorderWidth: 2
    readonly property real panelMargin: -Math.ceil(panelBorderWidth)

    function debugPrint(obj) {
        console.log(obj)
        for (const key in obj) {
            if (typeof(obj[key]) !== "undefined") {
                console.log(key)
            }
        }
    }

    component VBar : Rectangle {
        height: parent.height
        width: 2
        color: "#aaa"
    }

    component DebugRect : Rectangle {
        anchors.fill: parent
        z: 200
        color: 'transparent'
        border {
            width: 1
            color: "yellow"
        }
    }

    component RoundedRect : Rectangle {
        anchors {
            topMargin: panelMargin
            leftMargin: panelMargin
            rightMargin: panelMargin
            bottomMargin: panelMargin
        }
        bottomLeftRadius: panelRadius
        bottomRightRadius: panelRadius
        color: backgroundColor
        border {
            width: panelBorderWidth
            color: panelBorderColor
        }
    }

    Item {
        id: pipewire

        readonly property PwNode node: Pipewire.defaultAudioSink

        property bool is_mute
        property string volume

        PwObjectTracker {
            objects: [pipewire.node]
        }

        property string prettyVolume: {
            const audio = node?.audio;
            if (typeof audio !== "object") {
                return "unknown";
            }
            is_mute = audio.muted;
            volume = (audio.volume * 100).toFixed(0);
        }
    }

    Niri {
        id: niri
        Component.onCompleted: connect()

        onErrorOccurred: err => console.error(err)
    }

    SystemClock {
        id: sysclock
        precision: SystemClock.Minutes
    }

    PanelWindow {
        id: toppanel
        anchors { top: true; left: true; right: true; }
        color: "transparent"

        implicitHeight: 32

        RoundedRect {
            anchors.fill: left_panel
            bottomLeftRadius: 0
        }
        Row {
            id: left_panel
            height: 30

            leftPadding: 6
            rightPadding: 4
            topPadding: 4
            bottomPadding: 4

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

        RoundedRect {
            anchors.fill: middle_panel
            visible: middle_panel.visible
        }
        Row {
            id: middle_panel
            visible: Mpris.players.values.length > 0
            height: 30

            anchors.horizontalCenter: parent.horizontalCenter

            leftPadding: 4
            rightPadding: 4
            topPadding: 4
            bottomPadding: 4

            Repeater {
                model: Mpris.players.values

                Row {
                    leftPadding: 4
                    rightPadding: 4

                    Row {
                        visible: index > 0
                        height: parent.height
                        rightPadding: 8

                        VBar { }
                    }

					IconImage {
						implicitSize: 18
						source: Quickshell.iconPath("media-seek-backward")
                        MouseArea {
                            visible: canGoPrevious
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: modelData.previous()
                        }
					}

                    IconImage {
                        implicitSize: 18
                        source: {
                            switch (playbackState) {
                                case MprisPlaybackState.Playing:
                                    return Quickshell.iconPath("media-playback-playing");
                                case MprisPlaybackState.Paused:
                                    return Quickshell.iconPath("media-playback-paused");
                                case MprisPlaybackState.Stopped:
                                    return Quickshell.iconPath("media-playback-stopped");
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: modelData.togglePlaying()
                        }
                    }

					IconImage {
						implicitSize: 18
						source: Quickshell.iconPath("media-seek-forward")
                        MouseArea {
                            visible: canGoNext
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: modelData.next()
                        }
					}

                    Text {
                        topPadding: -2
                        leftPadding: 4
                        text: `${trackArtist} - ${trackTitle}`
                        color: activeColor
                        font.pixelSize: 16
                        width: 260
                        elide: Text.ElideRight
                    }
                }
            }
        }

        RoundedRect {
            anchors.fill: right_panel
            bottomRightRadius: 0
        }
        Row {
            id: right_panel
            height: 30

            anchors.right: parent.right

            leftPadding: 12
            rightPadding: 12
            topPadding: 4
            bottomPadding: 4

            Row {
                spacing: 12

                Row {
                    spacing: 2

					IconImage {
						implicitSize: 22
						source: pipewire.is_mute ? Quickshell.iconPath("player-volume-muted") : Quickshell.iconPath("player-volume")
					}

                    Text {
                        visible: !pipewire.is_mute
                        text: pipewire.prettyVolume
                        color: activeColor
                        font.pixelSize: 16
                    }
                }

                VBar { }

                Text {
                    text: Qt.formatDateTime(sysclock.date, "hh:mm - ddd, d MMM")
                    color: activeColor
                    font.pixelSize: 16
                }
            }
        }
    }
}
