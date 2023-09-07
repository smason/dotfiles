#!/bin/sh

sleep 1

region="$(swaymsg -t get_tree | jq -j '.. | select(.type?) | select(.focused).rect | "\(.x),\(.y) \(.width)x\(.height)"')"

echo "capturing $region"

exec grim -g "$region"
