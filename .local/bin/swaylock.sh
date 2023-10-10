#!/bin/bash

set -eufo pipefail

case "${1:-}" in
  # minimal screen fadeout, https://git.sr.ht/~emersion/chayang
  slow) chayang -d 10;;
  fast) chayang -d 0.3;;
esac

exec swaylock -f -F -c 000000
