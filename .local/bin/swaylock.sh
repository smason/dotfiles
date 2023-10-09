#!/bin/bash

set -eufo pipefail

case "${1:-}" in
  # minimal screen fadeout, https://git.sr.ht/~emersion/chayang
  fade) chayang;;
esac

exec swaylock -f -F -c 000000
