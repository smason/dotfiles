#!/usr/bin/python
# -*- coding: utf-8 -*-

#
# Copyright (c) 2013-2014, Kamil Wilas (wilas.pl)
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Example usage:
# echo 'Hello World!' | python keys2vb.py
#
# Note:
# Script work with python 2.6+ and python 3
# When scancode not exist for given char
# then script exit with status code 1 and an error is write to stderr.
#
# Helpful links - scancodes:
# - basic: http://humbledown.org/files/scancodes.l
# - basic: http://www.win.tue.nl/~aeb/linux/kbd/scancodes-1.html
# - make and break codes (c+0x80): http://www.win.tue.nl/~aeb/linux/kbd/scancodes-10.html
# - make and break codes table: http://stanislavs.org/helppc/make_codes.html
# - https://github.com/jedi4ever/veewee/blob/master/lib/veewee/provider/core/helper/scancode.rb
#
from __future__ import absolute_import, division, print_function, unicode_literals

import sys
import re

def _make_scancodes(key_map, str_pattern):
    scancodes = {}
    for keys in key_map:
        offset = key_map[keys]
        for idx, k in enumerate(list(keys)):
            scancodes[k] = str_pattern % (idx + offset, idx + offset + 0x80)
    return scancodes

def get_one_char_codes():
    key_map = {
        '1234567890-='  : 0x02,
        'qwertyuiop[]'  : 0x10,
        'asdfghjkl;\'`' : 0x1e,
        '\\zxcvbnm,./'  : 0x2b
    }
    scancodes = _make_scancodes(key_map, '%02x %02x')
    # Shift keys
    key_map =  {
        '!@#$%^&*()_+'  : 0x02,
        'QWERTYUIOP{}'  : 0x10,
        'ASDFGHJKL:"~'  : 0x1e,
        '|ZXCVBNM<>?'   : 0x2b
    }
    scancodes.update(_make_scancodes(key_map, '2a %02x %02x aa'))
    return scancodes

def get_multi_char_codes():
    scancodes = {
        '<Enter>'       : '1c 9c',
        '<Backspace>'   : '0e 8e',
        '<Spacebar>'    : '39 b9',
        '<Return>'      : '1c 9c',
        '<Esc>'         : '01 81',
        '<Tab>'         : '0f 8f',
        '<KillX>'       : '1d 38 0e b8',
        '<Wait>'        : 'wait',
        '<Up>'          : '48 c8',
        '<Down>'        : '50 d0',
        '<PageUp>'      : '49 c9',
        '<PageDown>'    : '51 d1',
        '<End>'         : '4f cf',
        '<Insert>'      : '52 d2',
        '<Delete>'      : '53 d3',
        '<Left>'        : '4b cb',
        '<Right>'       : '4d cd',
        '<Home>'        : '47 c7',
        '<Lt>'          : '2a 33 b3 aa', #to type '<' - e.g. <Enter> literally
    }
    # F1..F10
    for idx in range(1,10):
        scancodes['<F%s>' % idx] = '%02x' % (idx + 0x3a)
    # VT1..VT12 (Switch to Virtual Terminal)
    for idx in range(1,12):
        # LeftAlt + RightCtrl + F1-12
        scancodes['<VT%s>' % idx] = '38 e0 1d %02x b8 e0 9d %02x'\
                % (idx + 0x3a, idx +0xba)
    return scancodes

def process_multiply(input):
    # process <Multiply(what,times)>
    # example usage: <Multiply(<Wait>,4)> --> <Wait><Wait><Wait><Wait>
    # key thing about multiply_regexpr: match is non-greedy
    multiply_regexpr = '<Multiply\((.+?),[ ]*([\d]+)[ ]*\)>'
    for match in re.finditer(r'%s' % multiply_regexpr, input):
        what = match.group(1)
        times = int(match.group(2))
        # repeating a string given number of times
        replacement = what * times
        # replace Multiply(what,times)> with already created replacement
        input = input.replace(match.group(0), replacement)
    return input

def translate_chars(input):
    # create list to collect information about input string structure
    # -1 mean no key yet assign to cell in array
    keys_array = [-1] * len(input)

    multi_char_regexpr = '(<[^<> ]+>)';
    spc_scancodes = get_multi_char_codes()
    # proces multi-char codes/marks (special)
    # find all special codes in input string
    # and mark correspondence cells in keys_array
    for match in re.finditer(r'%s' % multi_char_regexpr, input):
        spc = match.group(1)
        if not spc in spc_scancodes:
            continue
        s = match.start()
        e = match.end()
        # mark start pos given match as scancode in keys_array
        keys_array[s] = spc_scancodes[spc]
        # mark rest pos given match as empty string in keys_array
        for i in range(s+1, e):
            keys_array[i] = ''

    # process single-char codes
    scancodes = get_one_char_codes()
    # convert input string to list
    input_list = list(input)
    # check only not assign yet (with value equal -1) cells in keys_array
    for index, _ in enumerate(keys_array):
        if keys_array[index] != -1:
            continue
        try:
            keys_array[index] = scancodes[input_list[index]]
        except KeyError:
            sys.stderr.write('Error: Unknown symbol found - %s\n'
                    % repr(input_list[index]))
            sys.exit(1)

    # remove empty string from keys_array
    keys_array = [x for x in keys_array if x != '']
    return keys_array


if __name__ == "__main__":
    # read from stdin
    input = sys.stdin.readlines()
    # convert input list to string
    input = ''.join(input).rstrip('\n')
    # process multiply
    input = process_multiply(input)
    # replace white-spaces with <Spacebar>
    input = input.replace(' ', '<Spacebar>')
    input = input.replace('\n', '<Enter>')
    input = input.replace('\t', '<Tab>')
    # process keys
    keys_array = translate_chars(input)
    # write result to stdout
    print(' '.join(keys_array))

# vim modeline
# vim: tabstop=4 expandtab shiftwidth=4 softtabstop=4
