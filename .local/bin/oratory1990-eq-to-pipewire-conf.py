import argparse
import csv
import re
from dataclasses import dataclass

@dataclass
class Filter:
    filter: str
    freq: str
    gain: str
    qfactor: str

def field_parser(regex):
    compiled = re.compile(regex)
    def inner(text):
        match = compiled.match(text)
        assert match
        return match.group(1)
    return inner


P_FREQ = field_parser(r'^([0-9]+) Hz$')
P_GAIN = field_parser(r'^(-?[0-9]+\.[0-9]+) dB$')
P_QF = field_parser(r'^(-?[0-9]+\.[0-9]+)$')


FTYPES = {
    "PEAK": "bq_peaking",
    "LOW_SHELF": "bq_lowshelf",
    "HIGH_SHELF": "bq_highshelf",
}


def parse_file(path: str):
    rows = csv.reader(open(path))
    header = next(rows)
    yield Filter("bq_highshelf", "0.0", P_GAIN(header[-1]), "1.0")
    for _, ftype, freq, gain, qf, _ in rows:
        yield Filter(FTYPES[ftype], P_FREQ(freq), P_GAIN(gain), P_QF(qf))


def parse_args():
    parser = argparse.ArgumentParser(
        description="Translate from oratory1990 EQ presets to Pipewire config",
    )
    parser.add_argument("csv", help="CSV table extracted from PDF")
    return parser.parse_args()


def main():
    args = parse_args()
    for band, f in enumerate(parse_file(args.csv), 1):
        node = (
            "{ "
            f"type=builtin name=eq_band_{band} label={f.filter} "
            f'control={{ "Freq" = {f.freq} "Gain" = {f.gain} "Q" = {f.qfactor} }}'
            " }"
        )
        print(node)


if __name__ == "__main__":
    main()
