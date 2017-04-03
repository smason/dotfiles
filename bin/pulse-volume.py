import sys
import subprocess

from pulsectl import Pulse, PulseVolumeInfo

[_,diff_str] = sys.argv
diff = float(diff_str)

def formatVolume(values):
    return "[{}]".format(', '.join(
        '{:.2g}'.format(v) for v in values))

with Pulse('volume-changer') as pulse:
    for sink in pulse.sink_list():
        if 'bluez.path' in sink.proplist:
            args = [
                'dbus-send', '--system', '--print-reply',
                '--dest=org.bluez', sink.proplist['bluez.path'],
                'org.bluez.MediaControl1.Volume{}'.format(
                    'Down' if diff < 0 else 'Up'),
            ]
            subprocess.run(args, check=True)
        else:
            old = sink.volume

            # perceived-volume is a logarithmic quantity
            mul = 2 ** diff
            new = [v * mul for v in old.values]

            # set the volume
            pulse.volume_set(sink, PulseVolumeInfo(new))

            # display something nice
            print("volume changed: {old} => {new}".format(
                old=formatVolume(old.values), new=formatVolume(new)))
