from argparse import ArgumentParser

from alsaaudio import card_indexes, card_name, Mixer, PCM_PLAYBACK


CARDS = {
    card_name(i)[0]: i for i in card_indexes()
}


def parseargs():
    parser = ArgumentParser()
    parser.add_argument(
        'mode', choices={'mute', 'micmute', 'lower', 'raise'})
    parser.add_argument(
        '--card', default="HDA Intel PCH", choices=CARDS.keys())
    return parser.parse_args()


def main():
    args = parseargs()

    def mixer(control):
        return Mixer(control, cardindex=CARDS[args.card])

    if args.mode == 'mute':
        m = mixer('Master')
        m.setmute(not any(m.getmute()))
    elif args.mode == 'micmute':
        m = mixer('Capture')
        cur = any(v > 0 for v in m.getrec())
        m.setrec(not cur)
    elif args.mode == 'lower':
        m = mixer('Master')
        [level] = m.getvolume(PCM_PLAYBACK)
        m.setvolume(int(level / 1.1 + 0.5))
    elif args.mode == 'raise':
        m = mixer('Master')
        [level] = m.getvolume(PCM_PLAYBACK)
        m.setvolume(min(100, int(level * 1.1 + 0.5)))
    else:
        assert False, args.mode


if __name__ == '__main__':
    main()
