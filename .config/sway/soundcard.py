from argparse import ArgumentParser

from pulsectl import Pulse


def parseargs():
    parser = ArgumentParser()
    parser.add_argument("mode", choices={"mute", "micmute", "lower", "raise"})
    return parser.parse_args()


def main():
    args = parseargs()

    pulse = Pulse("sway-volume-tool")
    sink = pulse.sink_default_get()
    source = pulse.source_default_get()

    if args.mode == "mute":
        pulse.mute(sink, mute=not sink.mute)
    elif args.mode == "micmute":
        pulse.mute(source, mute=not source.mute)
    elif args.mode == "lower":
        pulse.volume_change_all_chans(sink, -0.05)
    elif args.mode == "raise":
        pulse.volume_change_all_chans(sink, +0.05)
    else:
        assert False, args.mode


if __name__ == "__main__":
    main()
