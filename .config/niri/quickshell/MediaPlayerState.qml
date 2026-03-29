import QtQuick
import QtQuick.Layouts
import Quickshell.Widgets
import Quickshell.Services.Mpris

Row {
    id: self

    required property MprisPlayer player
    property color textColor: "white"
    property real textWidth: 100

    IconImage {
        height: parent.height
    	implicitSize: 18
        source: AppGlobals.playbackIconBackward
        MouseArea {
            visible: self.player?.canGoPrevious ?? false
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: self.player.previous()
        }
    }

    IconImage {
        height: parent.height
        implicitSize: 18
        source: AppGlobals.getPlaybackIcon(self.player);

        MouseArea {
            visible: self.player?.canTogglePlaying ?? false
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: self.player.togglePlaying()
        }
    }

	IconImage {
        height: parent.height
		implicitSize: 18
		source: AppGlobals.playbackIconForward
        MouseArea {
            visible: self.player?.canGoNext ?? false
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: self.player.next()
        }
	}

    Text {
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
