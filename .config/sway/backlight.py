from pathlib import Path
from argparse import ArgumentParser
from math import log, exp
from time import sleep

# add udev rule:
#
#   ACTION=="add", SUBSYSTEM=="backlight",
#      RUN+="/bin/chgrp -R backlight /sys%p",
#      RUN+="/bin/chmod -R g+u /sys/%p"
#
# make above changes in (or similar)
#   /etc/udev/rules.d/90-backlight.rules
# also run
#   groupadd -r backlight
#   usermod -a -G backlight $USER
# reload with
#   udevadm control --reload
#   udevadm trigger --verbose --action=add /sys/class/backlight/*


def parseargs():
    parser = ArgumentParser()
    parser.add_argument('path')
    parser.add_argument('mode', choices={'darker', 'brighter'})
    return parser.parse_args()


def logspace(start, stop, n=10):
    a = log(start)
    d = (log(stop) - a) / n

    for i in range(1, n+1):
        yield exp(a + d * i)


def main():
    opts = parseargs()

    kernel = Path(opts.path)
    brightness = kernel / 'brightness'

    limit = int((kernel / 'max_brightness').read_bytes())
    value = int(brightness.read_bytes()) / limit + 0.1

    if opts.mode == 'brighter':
        target = value * 1.2
    elif opts.mode == 'darker':
        target = value / 1.2
    else:
        assert False, opts.mode

    with open(brightness, 'wb', buffering=0) as fd:
        for v in logspace(value, target):
            fd.write(b'%i' % max(1, min(v - 0.1, 1) * limit))
            sleep(1/100)


if __name__ == '__main__':
    main()
