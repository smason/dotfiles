from argparse import ArgumentParser

from alsaaudio import Mixer, PCM_PLAYBACK, PCM_CAPTURE


def parseargs():
    parser = ArgumentParser()
    parser.add_argument(
        'mode', choices={'mute', 'micmute', 'lower', 'raise'})
    return parser.parse_args()


def main():
    args = parseargs()

    if args.mode == 'mute':
        m = Mixer('Master')
        m.setmute(not any(m.getmute()))
    elif args.mode == 'micmute':
        m = Mixer('Capture')
        cur = any(v > 0 for v in m.getrec())
        m.setrec(not cur)
    elif args.mode == 'lower':
        m = Mixer('Master')
        [level] = m.getvolume(PCM_PLAYBACK)
        m.setvolume(int(level / 1.1 + 0.5))
    elif args.mode == 'raise':
        m = Mixer('Master')
        [level] = m.getvolume(PCM_PLAYBACK)
        m.setvolume(min(100, int(level * 1.1 + 0.5)))
    else:
        assert False, args.mode


if __name__ == '__main__':
    main()
