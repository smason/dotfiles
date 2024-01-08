#!/bin/bash

set -eufo pipefail

curl -s "https://archlinux.org/mirrorlist/?country=GB&country=DE&country=FR&protocol=https&use_mirror_status=on" \
  | sed -e 's/^#Server/Server/' -e '/^#/d' \
  | rankmirrors -v -n 5 --max-time 1 -
