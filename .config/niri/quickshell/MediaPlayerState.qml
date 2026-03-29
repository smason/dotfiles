import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.Mpris

Row {
    id: self

    required property MprisPlayer player
    property color textColor: "white"
    property real textWidth: 100

    IconImage {
    	implicitSize: 18
    	source: Quickshell.iconPath("media-seek-backward")
        MouseArea {
            visible: self.player?.canGoPrevious ?? false
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: self.player.previous()
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
        source: stateIcon.get(self.player?.playbackState ?? MprisPlaybackState.Stopped);

        MouseArea {
            visible: self.player?.canTogglePlaying ?? false
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: self.player.togglePlaying()
        }
    }

	IconImage {
		implicitSize: 18
		source: Quickshell.iconPath("media-seek-forward")
        MouseArea {
            visible: self.player?.canGoNext ?? false
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: self.player.next()
        }
	}

    Text {
        topPadding: -2
        leftPadding: 4
        text: {
            const player = self.player;
            if (!player) {
                return "[ unknown ]";
            }
            return `${player.trackArtist} - ${player.trackTitle}`
        }
        color: self.textColor
        font.pixelSize: 16
        width: self.textWidth
        elide: Text.ElideRight

        MouseArea {
            visible: self.player?.canRaise ?? false
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: self.player.raise()
        }
    }
}
