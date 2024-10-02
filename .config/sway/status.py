from bisect import bisect_left
from math import log
from pathlib import Path
from time import sleep, strftime, time
import traceback

from alsaaudio import PCM_PLAYBACK, Mixer, card_indexes, card_name
from psutil import cpu_percent, disk_io_counters, net_io_counters

EMOJI_DIM_BUTTON = '\U0001F505'
EMOJI_BRIGHT_BUTTON = '\U0001F506'

EMOJI_MUTED_SPEAKER = '\U0001F507'
EMOJI_LOW_VOL_SPEAKER = '\U0001F508'
EMOJI_MED_VOL_SPEAKER = '\U0001F509'
EMOJI_HIGH_VOL_SPEAKER = '\U0001F50A'

EMOJI_BAT = '\U0001F50B'
EMOJI_AC = '\U0001F50C'
EMOJI_LOW_BAT = '\U0001FAAB'

EMOJI_HDD = '\U0001F5B4'
EMOJI_NET = '\U0001F5A7'

def linear_to_db(value):
    return log(value, 10) * 10


def si_prefix(n, binary=True):
    if n == 0:
        return "0"

    if n < 100:
        fix = ""
    else:
        kilo = 1024 if binary else 1000

        for fix in "kMGTPEZY":
            n /= kilo
            if n < 100:
                break

    if binary:
        fix = f"{fix}i"

    if n < 10:
        if n < 1:
            return f"{n:.2f}{fix}"
        return f"{n:.1f}{fix}"
    return f"{n:.0f}{fix}"


def get_datetime():
    return strftime(
        "(%b %a %z) %Y-%m-%d %H:%M:%S",
    )


def get_cpu():
    cpu = cpu_percent() / 100
    return f"CPU {cpu:.0%}"


POWER_SUPPLY_CAPACITY = "POWER_SUPPLY_CAPACITY"
POWER_SUPPLY_CHARGE_NOW = "POWER_SUPPLY_CHARGE_NOW"
POWER_SUPPLY_CURRENT_NOW = "POWER_SUPPLY_CURRENT_NOW"
POWER_SUPPLY_STATUS = "POWER_SUPPLY_STATUS"
POWER_SUPPLY_VOLTAGE_NOW = "POWER_SUPPLY_VOLTAGE_NOW"

def get_battery():
    try:
        with open("/sys/class/power_supply/BAT0/uevent") as fd:
            text = fd.read()
    except Exception as err:
        traceback.print_exception(err)
        return f"error {EMOJI_BAT}"

    attrs = dict(line.split('=', 1) for line in text.splitlines())
    status = attrs.get(POWER_SUPPLY_STATUS, "")
    capacity = attrs.get(POWER_SUPPLY_CAPACITY, "")

    if status.startswith("Discharging"):
        if capacity and int(capacity) >= 30:
            symbol = EMOJI_BAT
        else:
            symbol = EMOJI_LOW_BAT
    elif status.startswith("Charging") or status.startswith("Not charging"):
        symbol = EMOJI_AC
    elif status.startswith("Full"):
        return EMOJI_AC
    else:
        return f"{status!r} {EMOJI_BAT}"

    voltage = attrs.get(POWER_SUPPLY_VOLTAGE_NOW, "")
    current = attrs.get(POWER_SUPPLY_CURRENT_NOW, "")
    if voltage and current:
        power = float(voltage) * float(current) * 1e-12
        return f"{capacity}% {symbol} @{power:.1f}W"
    else:
        return f"{capacity}% {symbol}"


def backlight_gen():
    kernel = Path("/sys/class/backlight/intel_backlight")

    brightness = kernel / "brightness"
    limit = int((kernel / "max_brightness").read_bytes())

    while True:
        value = int(brightness.read_bytes())

        if value > 1:
            db = linear_to_db(value / limit + 0.01)
            yield f"{db:.1f}dB {EMOJI_BRIGHT_BUTTON}"
        else:
            yield EMOJI_DIM_BUTTON


def get_mixer():
    for card in card_indexes():
        short_name, _ = card_name(card)
        if short_name == "HDA Intel PCH":
            return Mixer(control="Master", cardindex=card)


def sound_gen():
    mixer = get_mixer()

    vol_lookup = [
        (0, EMOJI_MUTED_SPEAKER),
        (30, EMOJI_LOW_VOL_SPEAKER),
        (60, EMOJI_MED_VOL_SPEAKER),
        (1000, EMOJI_HIGH_VOL_SPEAKER),
    ]

    while True:
        mixer.handleevents()

        msg = EMOJI_MUTED_SPEAKER

        if not any(mixer.getmute()):
            [vol] = mixer.getvolume(PCM_PLAYBACK)

            if vol > 0:
                db = linear_to_db(vol / 100)
                idx = bisect_left(vol_lookup, vol, key=lambda x: x[0])
                msg = f"{db:.1f}dB {vol_lookup[idx][1]}"
        yield msg


def rw_stats_gen(name, fn):
    last_time = time()
    last = fn()
    yield f"{name} i/o"

    while True:
        cur_time = time()
        cur = fn()
        delta = cur_time - last_time

        read = si_prefix((cur[0] - last[0]) / delta)
        write = si_prefix((cur[1] - last[1]) / delta)

        delta = yield f"{name} {read}B/s - {write}B/s"
        last = cur
        last_time = cur_time


def disk_rw_stats():
    x = disk_io_counters()
    return x.read_bytes, x.write_bytes


def net_io_stats():
    x = net_io_counters()
    return x.bytes_recv, x.bytes_sent


def main():
    disk = rw_stats_gen(EMOJI_HDD, disk_rw_stats)
    net = rw_stats_gen(EMOJI_NET, net_io_counters)
    backlight = backlight_gen()
    sound = sound_gen()

    while True:
        # trying to keep fixed width items on the right
        parts = (
            next(net),
            next(disk),
            get_battery(),
            # get_cpu(),
            next(backlight),
            next(sound),
        )
        line = " | ".join(parts)

        print(f"{line} | {get_datetime()}", flush=True)

        sleep(5 - time() % 5)


if __name__ == "__main__":
    main()
