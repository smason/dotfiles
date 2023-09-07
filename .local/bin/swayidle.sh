#!/bin/sh

set -euf -o pipefail

lock="swaylock -f -F -c 000000"

exec swayidle -w \
     timeout 300 "$lock" \
     timeout 600 'swaymsg "output * dpms off"' resume 'swaymsg "output * dpms on"' \
     before-sleep "$lock" \
     lock "$lock"
