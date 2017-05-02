import time
import argparse
import subprocess

# Uses the pulsectl package for device and sink enumeration.  I.e. if
# the import below fails run the following command
#    pip install -U pulsectl
from pulsectl import Pulse, PulseVolumeInfo


def default_arg_parser():
    parser = argparse.ArgumentParser(
        description="Pulse & Bluetooth audio volume control")
    parser.add_argument('change', type=float, nargs='?', help=(
        'amount to change volume'))
    parser.add_argument('--reset', action='store_true', help=(
        "Perform a reset of Bluetooth audio devices"))

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
    new = PulseVolumeInfo([v * mul for v in old.values])

    pulse.volume_set(sink, new)

    return (old, new)


def send_volchange(sink, change):
    if 'bluez.path' in sink.proplist:
        msg = 'Down' if change < 0 else 'Up'
        # ask the bluetooth device to change its internal amplifier.
        # doing anything within the local volume seems wrong!
        dbus_send_bluez_message(
            sink.proplist['bluez.path'],
            'org.bluez.MediaControl1.Volume{}'.format(msg))

        return ['Bluetooth Volume {}'.format(msg)]

    # set the volume
    (old, new) = pulse_send_logchange(sink, change)

    # use the mean volume across all channels for notification
    mean = sum(new.values) / len(new.values)
    return [
        '-h', 'int:value:{}'.format(int(100 * mean)), 'Volume'
    ]


def send_reset(sink):
    off = None
    a2dp = None
    for profile in card.profile_list:
        if profile.name == 'off':
            off = profile
        elif profile.name == 'a2dp_sink':
            a2dp = profile

    # implicitly checks that this is a bluetooth device
    #   (other card types won't have the profile names)
    if off and a2dp:
        pulse.card_profile_set(card, off)
        # TODO: why do I need a pause in here, changing too quickly
        # breaks the device!
        time.sleep(0.05)
        pulse.card_profile_set(card, a2dp)


if __name__ == '__main__':
    args = default_arg_parser().parse_args()

    with Pulse('volume-changer') as pulse:
        if args.change:
            for sink in pulse.sink_list():
                notify_args = send_volchange(sink, args.change)
                subprocess.run(['notify-send']+notify_args+[sink.description],
                               check=True)

        if args.reset:
            for card in pulse.card_list():
                send_reset(card)
