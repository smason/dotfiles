from time import time, sleep, strftime
from math import log

from alsaaudio import Mixer, PCM_PLAYBACK
from psutil import cpu_percent, disk_io_counters, net_io_counters


DB_SCALE = log(10) / 10
mixer = Mixer()


def si_prefix(n, binary=True):
    if n < 100:
        return f'{n:.1f}'

    kilo = 1024 if binary else 1000

    for fix in "kMGTPEZY":
        n /= kilo
        if n < 100:
            break

    if binary:
        fix = f'{fix}i'

    if n < 1:
        return f'{n:.2f}{fix}'
    else:
        return f'{n:.1f}{fix}'


def get_datetime():
    return strftime(
        "(%b %a %z) %Y-%m-%d %H:%M:%S",
    )


def get_cpu():
    cpu = cpu_percent() / 100
    return f"CPU {cpu:.0%}"


def get_sound():
    mixer.handleevents()

    if not any(mixer.getmute()):
        [vol] = mixer.getvolume(PCM_PLAYBACK)

        if vol > 0:
            db = log(vol / 100) / DB_SCALE
            return f'Vol {db:.1f}dB'

    return 'Mute'


def rw_stats_gen(name, fn):
    last_time = time()
    last = fn()
    yield f'{name} i/o'

    while True:
        cur_time = time()
        cur = fn()
        delta = cur_time - last_time

        read = si_prefix((cur[0] - last[0]) / delta)
        write = si_prefix((cur[1] - last[1]) / delta)

        delta = yield f'{name} {read}B/s - {write}B/s'
        last = cur
        last_time = cur_time


def disk_rw_stats():
    x = disk_io_counters()
    return x.read_bytes, x.write_bytes


def net_io_stats():
    x = net_io_counters()
    return x.bytes_recv, x.bytes_sent


def main():
    disk_stats = rw_stats_gen('disk', disk_rw_stats)
    net_stats = rw_stats_gen('net', net_io_counters)

    while True:
        print(
            next(net_stats),
            next(disk_stats),
            get_sound(),
            get_cpu(),
            get_datetime(),
            sep=' | ')

        sleep(5 - time() % 5)


if __name__ == "__main__":
    main()
