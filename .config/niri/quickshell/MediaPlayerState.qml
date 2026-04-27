import QtQuick
import Quickshell.Widgets
import Quickshell.Services.Mpris

Row {
    id: self

    required property MprisPlayer player
    property real textWidth: 100

    property color textColor: "white"
    property color alphaBackground: AppGlobals.backgroundColor.alpha(0.8)

    property url playbackIcon
    property bool canTogglePlaying: false
    property bool canGoPrevious: false
    property bool canGoNext: false
    property bool canRaise: false

    property string description: {
        const player = self.player;
        if (!player) {
            self.playbackIcon = "";
            self.canTogglePlaying = false;
            self.canGoPrevious = false;
            self.canGoNext = false;
            self.canRaise = false;
            return "[ no player ]";
        }
        self.playbackIcon = AppGlobals.getPlaybackIcon(player);
        self.canTogglePlaying = player.canTogglePlaying;
        self.canGoPrevious = player.canGoPrevious;
        self.canGoNext = player.canGoNext;
        self.canRaise = player.canRaise;
        return `${player.trackArtist} - ${player.trackTitle}`
    }

    IconImage {
        height: parent.height
        implicitSize: 12
        source: AppGlobals.playbackIconBackward
        Rectangle {
            anchors.fill: parent
            visible: !self.canGoPrevious
            color: self.alphaBackground
        }
        MouseArea {
            visible: self.canGoPrevious
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: self.player.previous()
        }
    }

    IconImage {
        height: parent.height
        implicitSize: 22
        source: self.playbackIcon;
        Rectangle {
            anchors.fill: parent
            visible: !self.canTogglePlaying
            color: self.alphaBackground
        }
        MouseArea {
            visible: self.canTogglePlaying
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: self.player.togglePlaying()
        }
    }

	IconImage {
        height: parent.height
		implicitSize: 12
		source: AppGlobals.playbackIconForward
        Rectangle {
            anchors.fill: parent
            visible: !self.canGoNext
            color: self.alphaBackground
        }
        MouseArea {
            visible: self.canGoNext
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: self.player.next()
        }
	}

    Text {
        leftPadding: 6
        text: self.description
        color: self.textColor
        font.pixelSize: 16
        width: self.textWidth
        elide: Text.ElideRight

        MouseArea {
            visible: self.canRaise
            anchors.fill: parent
            cursorShape: Qt.WhatsThisCursor
            onClicked: self.player.raise()
        }
    }
}
