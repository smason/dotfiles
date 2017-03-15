import sys
import subprocess

from pulsectl import Pulse

[_,diff_str] = sys.argv
diff = float(diff_str)

with Pulse('volume-changer') as pulse:
    for sink in pulse.sink_list():
        bluez_path = sink.proplist['bluez.path']
        if bluez_path:
            args = [
                'dbus-send', '--system', '--print-reply',
                '--dest=org.bluez', bluez_path,
                'org.bluez.MediaControl1.Volume{}'.format(
                    'Down' if diff < 0 else 'Up'),
            ]
            subprocess.run(args, check=True)
        else:
            pulse.volume_change_all_chans(sink, diff)
