#!/bin/sh

process() {
	read opt && swaymsg $opt
	exit 0
}

wofi --show dmenu <<EOF | process
reload
exit
EOF
