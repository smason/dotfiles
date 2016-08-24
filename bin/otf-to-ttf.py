#!/usr/bin/env python

import sys
import fontforge as ff

ff.open(sys.argv[1]).generate(sys.argv[2])
