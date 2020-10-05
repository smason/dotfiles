#!/bin/sh

process() {
	read opt && swaymsg $opt
	exit 0
}

wofi --location 2 --show dmenu <<EOF | process
reload
exit
EOF
