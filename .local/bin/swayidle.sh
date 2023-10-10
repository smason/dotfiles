#!/bin/bash

set -eufo pipefail

lock=swaylock.sh

exec swayidle -w \
     timeout 300 "$lock slow" \
     timeout 600 'swaymsg "output * dpms off"' resume 'swaymsg "output * dpms on"' \
     before-sleep "$lock" \
     lock "$lock fast"
