pragma ComponentBehavior: Bound

// https://develop.kde.org/frameworks/breeze-icons/
//@ pragma IconTheme breeze-dark

import QtQuick
import Quickshell
import Quickshell.Services.Pipewire
import Quickshell.Services.Mpris
import Quickshell.Widgets
import Niri

ShellRoot {
    id: root

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
            topMargin: root.panelMargin
            leftMargin: root.panelMargin
            rightMargin: root.panelMargin
            bottomMargin: root.panelMargin
        }
        bottomLeftRadius: root.panelRadius
        bottomRightRadius: root.panelRadius
        color: root.backgroundColor
        border {
            width: root.panelBorderWidth
            color: root.panelBorderColor
        }
    }

    Item {
        id: pipewire

        readonly property PwNode node: Pipewire.defaultAudioSink

        PwObjectTracker {
            objects: [pipewire.node]
        }

        function toggleMute() {
            const audio = node?.audio;
            if (typeof audio === "object") {
                audio.muted = !audio.muted;
            }
        }

        property bool is_mute
        property string volume: {
            const audio = node?.audio;
            if (typeof audio === "object") {
                is_mute = audio.muted;
                return (audio.volume * 100).toFixed(0);
            }
            return "unk";
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

    component ScreenTop : PanelWindow {
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
                    required property int index
                    required property var modelData
                    required property bool isActive
                    readonly property int workspaceId: modelData.id

                    text: index

                    font.pixelSize: 16
                    font.weight: isActive ? 800 : 300
                    color: root.activeColor
                    leftPadding: 8
                    rightPadding: 8

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: niri.focusWorkspaceById(parent.workspaceId)
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
                    required property int index
                    required property MprisPlayer modelData

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
                            visible: modelData.canGoPrevious
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: modelData.previous()
                        }
					}

                    IconImage {
                        readonly property var stateIcon: {
                            const m = new Map();
                            m.set(MprisPlaybackState.Playing, Quickshell.iconPath("media-playback-playing"));
                            m.set(MprisPlaybackState.Paused, Quickshell.iconPath("media-playback-paused"));
                            m.set(MprisPlaybackState.Stopped, Quickshell.iconPath("media-playback-stopped"));
                            return m;
                        }

                        implicitSize: 18
                        source: stateIcon.get(modelData.playbackState);

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
                            visible: modelData.canGoNext
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: modelData.next()
                        }
					}

                    Text {
                        topPadding: -2
                        leftPadding: 4
                        text: `${modelData.trackArtist} - ${modelData.trackTitle}`
                        color: root.activeColor
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

                    Text {
                        visible: !pipewire.is_mute
                        text: pipewire.volume
                        color: root.activeColor
                        font.pixelSize: 16
                    }

					IconImage {
						implicitSize: 22
						source: {
						    if (pipewire.is_mute) {
						        return Quickshell.iconPath("player-volume-muted");
						    } else {
						        return Quickshell.iconPath("player-volume");
						    }
						}
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: pipewire.toggleMute();
                        }
					}
                }

                VBar { }

                Text {
                    text: Qt.formatDateTime(sysclock.date, "hh:mm - ddd, d MMM")
                    color: root.activeColor
                    font.pixelSize: 16
                }
            }
        }
    }

    Variants {
        model: Quickshell.screens
        ScreenTop { }
    }
}
