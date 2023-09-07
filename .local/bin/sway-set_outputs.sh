#!/bin/bash

set -euo pipefail

declare -a extra=()

for path in /sys/class/drm/card*/status; do
  dp="$(basename $(dirname $path))"
  dp="${dp/card[0-9]-/}"
  status=$(cat $path)
  if [ "$status" = connected -a "$dp" != eDP-1 ]; then
    extra+="$dp"
  fi
done

case "${1-}" in
  "")
    nextra="${#extra[*]}"
    if [ $nextra == 0 ]; then
      swaymsg output eDP-1 position 0 0
    elif [ $nextra == 1 ]; then
      swaymsg output "$extra" position 0 0
      swaymsg output eDP-1    position 100 1440
    else
      echo "not sure what to do wth extra connected monitors: $extra"
      exit 1
    fi
    ;;
  k1-092)
    swaymsg output DP-4  position 0 0
    swaymsg output DP-3  position 1920 0
    swaymsg output eDP-1 position 0 1080
    ;;
  *)
    echo "unrecognised config '${1}'"
    exit 1;;
esac
