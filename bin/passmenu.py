import os
import re
import glob

import subprocess
from pathlib import Path

class PasswordStoreError(Exception):
    pass

regex_username = re.compile(r"""
^\s*
(?:user(?:name)?|
   email|
   account
):?\s*
(?P<username>\S+)
\s*$
""", re.IGNORECASE | re.VERBOSE)

class PasswordEntry(object):
    def __init__(self, store, key, value):
        self.store = store
        self.key = key
        self.value = value
        self.password = self.value.splitlines()[0]

    # take a guess at the username
    def guess_username(self):
        # look for a username or email field
        for l in self.value.splitlines()[1:]:
            m = regex_username.match(l)
            # OK, found something
            if m:
                return m.group('username')

        # assume the last element in the key (i.e. the name of the file) is the username
        return Path(self.key).name

class PasswordStore(object):
    def __init__(self, store):
        self.store = store;
        self.gpg_opts = ['--quiet', '--yes', '--compress-algo=none', '--no-encrypt-to']

    def __str__(self):
        return 'passwordstore (for {dir})'.format(
            dir=repr(self.store))

    def items_for_store(self):
        dir_re = re.compile(r'^{dir}/(.*)\.gpg$'.format(
            dir=self.store))

        dir_glob = "{dir}/**/*.gpg".format(dir=self.store)
        for f in glob.iglob(dir_glob, recursive=True):
            match = dir_re.match(f)
            assert match
            yield match.group(1)

    def path_from_key(self, key):
        path = '{dir}/{key}.gpg'.format(
            dir=self.store, key=key)
        if not os.path.isfile(path):
            raise PasswordStoreError('key {key} not found under {store}'.format(
                store=self.store, key=key))
        return path

    # basically "pass show -m $key"
    def get(self, key):
        path = self.path_from_key(key)

        # set up command line args
        args = ['gpg']
        args.extend(self.gpg_opts)
        args.extend(['--decrypt', path])

        # execute GnuPG to get the password
        proc = subprocess.run(
            args, universal_newlines=True,
            stdout=subprocess.PIPE)

        # check it's all OK
        if proc.returncode:
            raise PasswordStoreError(
                "unable to decrypt entry {key}".format(
                    key=repr(key)))

        entry = PasswordEntry(self, key, proc.stdout)
        entry.path = path
        return entry

def default_arg_parser():
    default_store_path = os.environ.get(
        'PASSWORD_STORE_DIR',
        os.path.expanduser('~/.password-store'))

    parser = argparse.ArgumentParser()
    parser.add_argument('--store', help="set password store location",
                        default=default_store_path, metavar='PATH')
    parser.add_argument('--no-username', help="don't send/show username",
                        dest='username', action='store_false')
    parser.add_argument('--no-password', help="don't send/show password",
                        dest='password', action='store_false')
    parser.add_argument('--separator', help="Separator character to send between fields",
                        default='Tab', metavar='SEP')
    parser.add_argument('--terminator', help="Which character to send after all fields",
                        default='Return', metavar='TERM')
    parser.add_argument('--xdotool', help="send results through xdotool(1)",
                        action='store_true')
    return parser

def xdotool_stdin(lines, sep_key, term_key):
    dokey = "key --clearmodifiers {}\n"
    dotype = "type --clearmodifiers {}\n"

    lsep = ''
    if sep_key:
        lsep = dokey.format(sep_key)
    lterm = ''
    if term_key:
        lterm = dokey.format(term_key)

    return '{ops}{term}'.format(
        ops=lsep.join(dotype.format(l) for l in lines), term=lterm)

if __name__ == '__main__':
    import sys
    import argparse

    import dmenu

    args = default_arg_parser().parse_args()

    store = PasswordStore(args.store)

    item = dmenu.show(
        store.items_for_store())
    if not item:
        sys.exit(0)

    try:
        entry = store.get(item)
    except PasswordStoreError as err:
        sys.stderr.write('Error: {msg}'.format(msg=err))
        sys.exit(1)

    # get the keystrokes we want to send
    lines = []
    if args.username:
        lines.append(entry.guess_username())
    if args.password:
        lines.append(entry.password)

    proc = subprocess.run(
        ["xdotool", "-"], universal_newlines=True,
        input=xdotool_stdin(lines, args.separator, args.terminator))

    # check all is OK
    proc.check_returncode()

    sys.exit(0)
