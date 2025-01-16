import os
import re
import subprocess
from argparse import ArgumentParser, Namespace
from enum import Enum
from math import ceil, floor
from pathlib import Path
from select import select
from sys import stderr, stdout
from typing import Iterator


def _nonblocking_opener(path: str, flags: int) -> int:
    return os.open(path, flags | os.O_NONBLOCK)


# weird enum to keep mypy happy, see
# https://stackoverflow.com/q/69239403/1358308 and
# https://stackoverflow.com/q/78739565/1358308
class Specials(Enum):
    apply_now = 0


APPLY_NOW = Specials.apply_now


def get_changes(
    commsfifo: os.PathLike[str], args: Namespace
) -> Iterator[str | Specials]:
    """yield args.mode compatible values
    followed by APPLY_NOW to indicate that the change should be applied now as
    there's a gap in requests
    """
    yield args.mode

    try:
        # open in non-blocking mode so that the comms.read returns with whatever is available
        with open(commsfifo, "r+b", buffering=0, opener=_nonblocking_opener) as comms:
            rlist = [comms.fileno()]
            while True:
                # about to sleep, apply the current changes now
                yield APPLY_NOW
                try:
                    readable, _, _ = select(rlist, (), (), 10)
                except KeyboardInterrupt:
                    print("exiting", file=stderr)
                    return
                else:
                    if not readable:
                        return
                for line in comms.read().splitlines(keepends=False):
                    yield line.decode("ascii")
    finally:
        os.remove(commsfifo)


# changing brightness using the screen's percentages isn't very nice, a change
# from 0% to 5% is very noticeable while a change from 95% to 100% isn't.
# hence we transform brightness values to a linear scale and then perform
# multiplicative changes there
#
# my phone measures a white screen at 0% brightness giving 40 lux and 100% gave
# 280 lux, with reasonably linear intermediate values
#
# the multiplicative changes I use don't really care what units are used, so
# just add on the measured dark lux in terms of the percentage value
def bri_to_linear(brightness: float) -> float:
    return brightness + 20.0


def linear_to_bri(linear: float) -> float:
    return linear - 20.0


# parse the current brightness from the output of "ddcutil -t getvcp 0x10":
#   "VCP 10 C 20 100"
# this says we got VCP response for code 0x10, C=continuous value, currently at 10, max of 100
RE_VCP_BRIGHTNESS = re.compile(b"^VCP 10 C ([0-9]+) 100$", re.IGNORECASE)

# parse the I2C bus number from the output of "ddcutil -t detect":
#   "Display 1\n I2C bus: /dev/i2c-6\n DRM connector: card1-DP-1\n Monitor: GSM:LG ULTRAFINE:405NTRL42566"
# with some extra spaces in to look nice for humans
RE_I2C_BUS_NUM = re.compile(b" /dev/i2c-([0-9]+)$", re.MULTILINE)


def get_display_buses() -> list[int]:
    args = ["ddcutil", "--terse", "detect"]
    proc = subprocess.run(args, stdout=subprocess.PIPE, check=True)
    matches = RE_I2C_BUS_NUM.findall(proc.stdout)
    return list(map(int, matches))


# ddcutil takes about a second to get/set the display brightness, so we use
# a Unix named pipes to combine multiple runs of this program into a single
# setvcp call.  This has the advantage of not getting IO errors due to multiple
# instances of the program trying to access the I2C bus at the same time
def get_brightness(buses: list[int]) -> dict[int, int]:
    procs: dict[int, subprocess.Popen[bytes]] = {}
    # execute in parallel
    for bus in buses:
        args = ["ddcutil", "--terse", "--bus", str(bus), "getvcp", "0x10"]
        procs[bus] = subprocess.Popen(args, stdout=subprocess.PIPE)

    result: dict[int, int] = {}
    # wait to complete and collect results
    for bus, proc in procs.items():
        output, err = proc.communicate()
        if proc.returncode != 0:
            raise ValueError("ddcutil getvcp unsuccessful", output, err)
        match = RE_VCP_BRIGHTNESS.match(output)
        if not match:
            raise ValueError("unable to parse output", output)
        result[bus] = int(match.group(1))

    return result


def set_brightness(brightnesses: dict[int, int]) -> None:
    procs: dict[int, subprocess.Popen[bytes]] = {}
    for bus, value in brightnesses.items():
        args = ["ddcutil", "--bus", str(bus), "setvcp", "0x10", str(value)]
        procs[bus] = subprocess.Popen(args)

    # wait all the processes to complete
    for bus, proc in procs.items():
        output, err = proc.communicate()
        if proc.returncode != 0:
            raise ValueError("ddcutil setvcp unsuccessful", output, err)


def parseargs() -> Namespace:
    if root := os.environ.get("XDG_RUNTIME_DIR"):
        runtime_dir = Path(root) / "monitor-brightness"

    parser = ArgumentParser()
    parser.add_argument("mode", choices={"darker", "brighter"})
    parser.add_argument("--change", default=0.1, type=float)
    parser.add_argument("--runtime-dir", default=runtime_dir, type=Path)
    return parser.parse_args()


def apply_change(args: Namespace, brightness: int) -> int:
    change = 1.0 + args.change
    match args.mode:
        case "darker":
            result = floor(linear_to_bri(bri_to_linear(brightness) / change))
        case "brighter":
            result = ceil(linear_to_bri(bri_to_linear(brightness) * change))
        case _:
            raise ValueError("unknown mode", args.mode)

    if result < 0:
        return 0
    elif result > 100:
        return 100
    else:
        return result


def main() -> None:
    args = parseargs()

    rundir = args.runtime_dir
    if rundir is None:
        print("XDG_RUNTIME_DIR not set, using /tmp/monitor-brightness", file=stderr)
        rundir = Path("/tmp/monitor-brightness")

    rundir.mkdir(parents=True, exist_ok=True)
    commsfifo = rundir / "comms"

    try:
        # race to this line, first to succeed is the server
        os.mkfifo(commsfifo)
    except FileExistsError:
        with open(commsfifo, "r+b", buffering=0) as fd:
            fd.write(f"{args.mode}\n".encode("ascii"))
        return

    displays = get_brightness(get_display_buses())
    for bus, val in displays.items():
        print(f"display bus={bus} brightness={val}")

    for change in get_changes(commsfifo, args):
        if change is APPLY_NOW:
            set_brightness(displays)
            for bus, val in displays.items():
                print(f"display bus={bus} brightness={val}")
            stdout.flush()
        else:
            args.mode = change
            displays = {bus: apply_change(args, val) for bus, val in displays.items()}


if __name__ == "__main__":
    main()
