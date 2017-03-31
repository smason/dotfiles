import sys
import time
import argparse
import subprocess

from pulsectl import Pulse, PulseVolumeInfo

def default_arg_parser():
    parser = argparse.ArgumentParser(description="Pulse & Bluetooth audio volume control")
    parser.add_argument('change', help='amount to change volume', type=float, nargs='?')
    parser.add_argument('--reset', action='store_true',
                        help="Perform a reset of Bluetooth audio devices")

    return parser

def dbus_send_bluez_message(dest, method):
    args = [
        'dbus-send', '--system', '--print-reply',
        '--dest=org.bluez', dest, method
    ]
    return subprocess.run(args, check=True)

def pulse_send_logchange(sink, log_diff):
    old = sink.volume

    # perceived-volume is a logarithmic quantity
    mul = 2 ** log_diff
    new = [v * mul for v in old.values]

    pulse.volume_set(sink, PulseVolumeInfo(new))

    return (old,new)

def send_volchange(sink, change):
    if 'bluez.path' in sink.proplist:
        dbus_send_bluez_message(
            sink.proplist['bluez.path'],
            'org.bluez.MediaControl1.Volume{}'.format(
                'Down' if change < 0 else 'Up'))
        return

    # set the volume
    (old, new) = pulse_send_logchange(sink, change)

    # display something nice
    print("volume changed: {old} => {new}".format(
        old=formatVolume(old), new=formatVolume(new)))

def send_reset(sink):
    a2dp = None
    head = None
    for profile in card.profile_list:
        if profile.name == 'headset_head_unit':
            head = profile
        elif profile.name == 'a2dp_sink':
            a2dp = profile

    # implicitly checks that this is a bluetooth device
    #   (other card types won't have the profile names)
    if head and a2dp:
        pulse.card_profile_set(card, head)
        # TODO: why do I need a pause in here, changing too quickly breaks the device!
        time.sleep(0.3)
        pulse.card_profile_set(card, a2dp)

def formatVolume(values):
    return "[{}]".format(', '.join(
        '{:.2g}'.format(v) for v in values))

if __name__ == '__main__':
    args = default_arg_parser().parse_args()

    with Pulse('volume-changer') as pulse:
        if args.change:
            for sink in pulse.sink_list():
                send_volchange(sink, args.change)

        if args.reset:
            for card in pulse.card_list():
                send_reset(card)
