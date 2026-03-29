pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Mpris

Singleton {
    readonly property color activeColor: "#7bf"
    readonly property color backgroundColor: "#333"
    readonly property color panelBorderColor: "#888"
    readonly property real panelBorderWidth: 2
    readonly property int panelRadius: 12

    readonly property string playbackIconBackward: Quickshell.iconPath("media-seek-backward")
    readonly property string playbackIconForward: Quickshell.iconPath("media-seek-forward")

    readonly property var _playbackStateIcon: {
        const m = new Map();
        m.set(MprisPlaybackState.Playing, Quickshell.iconPath("media-playback-playing"));
        m.set(MprisPlaybackState.Paused, Quickshell.iconPath("media-playback-paused"));
        m.set(MprisPlaybackState.Stopped, Quickshell.iconPath("media-playback-stopped"));
        return m;
    }

    function getPlaybackIcon(player: MprisPlayer): string {
        return _playbackStateIcon.get(player?.playbackState ?? MprisPlaybackState.Stopped);
    }
}
