from argparse import ArgumentParser

from alsaaudio import PCM_PLAYBACK, VOLUME_UNITS_RAW, Mixer, card_indexes, card_name

CARDS = {card_name(i)[0]: i for i in card_indexes()}


def parseargs():
    parser = ArgumentParser()
    parser.add_argument("mode", choices={"mute", "micmute", "lower", "raise"})
    parser.add_argument("--card", default="HDA Intel PCH", choices=CARDS.keys())
    return parser.parse_args()


def main():
    args = parseargs()

    def mixer(control):
        return Mixer(control, cardindex=CARDS[args.card])

    if args.mode == "mute":
        m = mixer("Master")
        m.setmute(not any(m.getmute()))
    elif args.mode == "micmute":
        m = mixer("Capture")
        cur = any(v > 0 for v in m.getrec())
        m.setrec(not cur)
    elif args.mode == "lower":
        m = mixer("Master")
        lo, hi = m.getrange(PCM_PLAYBACK, units=VOLUME_UNITS_RAW)
        assert lo == 0
        [level] = m.getvolume(PCM_PLAYBACK, units=VOLUME_UNITS_RAW)
        level -= max(level // 10, 1)
        m.setvolume(max(level, 0), PCM_PLAYBACK, units=VOLUME_UNITS_RAW)
    elif args.mode == "raise":
        m = mixer("Master")
        lo, hi = m.getrange(PCM_PLAYBACK, units=VOLUME_UNITS_RAW)
        assert lo == 0
        [level] = m.getvolume(PCM_PLAYBACK, units=VOLUME_UNITS_RAW)
        level += max(level // 10, 1)
        m.setvolume(min(level, hi), PCM_PLAYBACK, units=VOLUME_UNITS_RAW)
    else:
        assert False, args.mode


if __name__ == "__main__":
    main()
