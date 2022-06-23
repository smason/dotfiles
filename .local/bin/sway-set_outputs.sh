#!/bin/sh

set -euo pipefail

case "$1" in
  k1-092)
    swaymsg output DP-4  position 0 0
    swaymsg output DP-3  position 1920 0
    swaymsg output eDP-1 position 0 1080
    ;;
  k1-082)
    swaymsg output DP-2  position 0 0
    swaymsg output eDP-1 position 100 1440
    ;;
esac
