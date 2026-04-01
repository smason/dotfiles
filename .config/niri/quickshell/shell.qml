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

    component RoundedRect : Rectangle {
        readonly property real panelMargin: -Math.ceil(AppGlobals.panelBorderWidth)

        anchors {
            topMargin: panelMargin
            leftMargin: panelMargin
            rightMargin: panelMargin
            bottomMargin: panelMargin
        }
        bottomLeftRadius: AppGlobals.panelRadius
        bottomRightRadius: AppGlobals.panelRadius
        color: AppGlobals.backgroundColor
        border {
            width: AppGlobals.panelBorderWidth
            color: AppGlobals.panelBorderColor
        }
    }

    PwObjectTracker {
        id: pipewire

        readonly property PwNode node: Pipewire.defaultAudioSink

        objects: [node]

        function toggleMute() {
            const audio = node?.audio;
            if (typeof audio === "object") {
                audio.muted = !audio.muted;
            }
        }

        property bool is_mute
        property string volume: {
            const audio = node?.audio;
            if (typeof audio !== "object") {
                return "unk";
            }
            this.is_mute = audio.muted;
            return (audio.volume * 100).toFixed(0);
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

    component ScreenPanel : PanelWindow {
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
                    color: AppGlobals.activeColor
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
                id: players
                model: Mpris.players.values

                Row {
                    required property int index
                    required property MprisPlayer modelData

                    anchors.verticalCenter: parent.verticalCenter

                    leftPadding: 4
                    rightPadding: 4

                    Row {
                        visible: parent.index > 0
                        height: parent.height
                        rightPadding: 8

                        VBar { }
                    }

                    MediaPlayerState {
                        player: parent.modelData
                        textColor: AppGlobals.activeColor
                        // make them a bit smaller as we get more
                        textWidth: 100 + (300 / players.count)
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

                    // text on the left so the icon doesn't move when clicked
                    Text {
                        visible: !pipewire.is_mute
                        text: pipewire.volume
                        color: AppGlobals.activeColor
                        font.pixelSize: 16
                    }

					IconImage {
					    height: parent.height
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
                    text: Qt.formatDateTime(sysclock.date, "hh:mm, ddd d MMM")
                    color: AppGlobals.activeColor
                    font.pixelSize: 16
                }
            }
        }
    }

    Variants {
        model: Quickshell.screens
        ScreenPanel {
            required property var modelData
        }
    }
}
