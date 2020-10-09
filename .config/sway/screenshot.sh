#!/bin/sh

# based on https://github.com/yschaeff/sway_screenshots/blob/master/screenshot.sh

set -euf -o pipefail

focused() {
	swaymsg -t get_tree | jq -r '.. | ((.nodes? + .floating_nodes?) // empty) | .[] | select(.focused and .pid) | .rect | "\(.x),\(.y) \(.width)x\(.height)"'
}

root="$HOME/Pictures"
filename="$root/screenshot-$(date '+%Y-%m-%dT%H-%H-%S').png"

exec grim -g "$(focused)" "$filename"
