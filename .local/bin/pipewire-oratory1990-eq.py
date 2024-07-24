#!/usr/bin/env python

import argparse
import json
import pathlib
import re
import string
import subprocess
import sys
import urllib.parse
from dataclasses import dataclass
from itertools import pairwise


@dataclass
class Filter:
    name: str
    filter: str
    freq: str
    gain: str
    qfactor: str


FTYPES = {
    "PK": "bq_peaking",
    "LSC": "bq_lowshelf",
    "HSC": "bq_highshelf",
}

# for parsing ParametricEQ.txt files from https://github.com/jaakkopasanen/AutoEq e.g. see
#   https://github.com/jaakkopasanen/AutoEq/blob/master/results/oratory1990/over-ear/Sony%20MDR-7506/Sony%20MDR-7506%20ParametricEQ.txt
RE_FILTER = (
    r"Filter [0-9]+: ON (?P<filter>[A-Z]+) "
    r"Fc (?P<freq>[0-9]+(?:\.[0-9]+)?) Hz "
    r"Gain (?P<gain>-?[0-9]+(?:\.[0-9]+)?) dB "
    r"Q (?P<qf>[0-9]+(?:\.[0-9]+)?)"
)

MODULE_DEF = string.Template("""\
{
    node.description = $description
    audio.channels = 2
    audio.position = [ FL FR ]
    capture.props = { node.name="effect_input.$name" media.class="Audio/Sink" }
    playback.props = { node.name="effect_output.$name" node.passive=true }
    filter.graph = {
        nodes = [\n$nodes\
        ]
        links = [\n$links\
        ]
        inputs = [ $input ]
        outputs = [ $output ]
    }
}
""")

def parse_file(fd):
    m = re.match(r"Preamp: (?P<gain>-?[0-9]+(?:\.[0-9]+)) dB", next(fd))
    yield Filter("preamp", "bq_highshelf", "0.0", m.group("gain"), "1.0")
    for i, line in enumerate(fd, 1):
        name = f"eq_band_{i}"
        m = re.match(RE_FILTER, line)
        filter = FTYPES[m.group("filter")]
        yield Filter(
            name, filter, m.group("freq"), m.group("gain"), m.group("qf")
        )


def parse_args():
    parser = argparse.ArgumentParser(
        description="Translate from AutoEq ParametricEq files to Pipewire config",
    )
    parser.add_argument("source", type=pathlib.Path, help="Text file from AutoEq repo")
    parser.add_argument("--description", "--desc", "-d", help="Human readable description")
    parser.add_argument("--name", "-c", help="Machine compatible identifier")
    args = parser.parse_args()
    name = urllib.parse.unquote(args.source.name)
    m = re.match(r"(.*) ParametricEQ.txt", name)
    # try and fill these in if the user didn't supply them
    if not args.description:
        args.description = f"{m.group(1)} Equaliser"
    if not args.name:
        keep = re.findall(r"([a-z0-9]+)", m.group(1), re.IGNORECASE)
        args.name = '_'.join(keep).lower()
    return args


def main():
    args = parse_args()
    with open(args.source) as fd:
        filters = list(parse_file(fd))

    nodes = []
    links = []

    for a, b in pairwise(filters):
        out = json.dumps(f"{a.name}:Out")
        inp = json.dumps(f"{b.name}:In")
        links.append(
            f"{{ output={out} input={inp} }}\n"
        )

    for f in filters:
        band = json.dumps(f.name)
        nodes.append(
            "{ "
            f"type=builtin name={band} label={f.filter} "
            f"control={{ Freq = {f.freq} Gain = {f.gain} Q = {f.qfactor} }}"
            " }\n"
        )

    head, tail = filters[0], filters[-1]
    filter = MODULE_DEF.substitute(
        description=json.dumps(args.description),
        name=args.name,
        nodes="".join(nodes),
        links="".join(links),
        input=json.dumps(f"{head.name}:In"),
        output=json.dumps(f"{tail.name}:Out"),
    )

    print(f"loaded: {args.source.name!r}", file=sys.stderr)

    try:
        subprocess.run(["pw-cli", "-m", "load-module", "libpipewire-module-filter-chain", filter])
    except KeyboardInterrupt:
        pass


if __name__ == "__main__":
    main()
