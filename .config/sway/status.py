from math import log
from pathlib import Path
from time import sleep, strftime, time

from alsaaudio import PCM_PLAYBACK, Mixer, card_indexes, card_name
from psutil import cpu_percent, disk_io_counters, net_io_counters

DB_SCALE = log(10) / 10

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


def battery_gen():
    kernel = Path("/sys/class/power_supply/BAT0")

    status = kernel / "status"
    capacity = kernel / "capacity"

    while True:
        stat = status.read_bytes()

        if stat.startswith(b"Discharging"):
            cap = int(capacity.read_bytes())
            if cap < 30:
                yield f"{EMOJI_LOW_BAT} {cap}%"
            else:
                yield f"{EMOJI_BAT} {cap}%"
        elif stat.startswith(b"Charging") or stat.startswith(b"Not charging"):
            cap = int(capacity.read_bytes())
            yield f"{EMOJI_AC} {cap}%"
        elif stat.startswith(b"Full"):
            yield f"{EMOJI_AC} full"
        else:
            yield f"{EMOJI_BAT} {stat!r}"


def backlight_gen():
    kernel = Path("/sys/class/backlight/intel_backlight")

    brightness = kernel / "brightness"
    limit = int((kernel / "max_brightness").read_bytes())

    while True:
        value = int(brightness.read_bytes())

        if value > 1:
            db = log(value / limit + 0.01) / DB_SCALE
            yield f"{EMOJI_BRIGHT_BUTTON} {db:.1f}dB"
        else:
            yield EMOJI_DIM_BUTTON


def get_mixer():
    for card in card_indexes():
        short_name, _ = card_name(card)
        if short_name == "HDA Intel PCH":
            return Mixer(control="Master", cardindex=card)


def sound_gen():
    mixer = get_mixer()

    while True:
        mixer.handleevents()

        msg = EMOJI_MUTED_SPEAKER

        if not any(mixer.getmute()):
            [vol] = mixer.getvolume(PCM_PLAYBACK)

            if vol > 0:
                db = log(vol / 100) / DB_SCALE
                msg = f"{EMOJI_LOW_VOL_SPEAKER} {db:.1f}dB"

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
    battery = battery_gen()

    while True:
        # trying to keep fixed width items on the right
        parts = (
            next(net),
            next(disk),
            next(battery),
            # get_cpu(),
            next(backlight),
            next(sound),
        )
        line = " | ".join(parts)

        print(f"{line} | {get_datetime()}", flush=True)

        sleep(5 - time() % 5)


if __name__ == "__main__":
    main()
