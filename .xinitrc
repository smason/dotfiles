#!/bin/sh

setxkbmap -model pc105 \
	  -layout gb \
	  -option ctrl:nocaps \
	  -option terminate:ctrl_alt_bksp

[ -f ~/.Xresources ] && xrdb ~/.Xresources

# disable capslock
xkbset nullify lock

# set screen resolution nicely
xrandr --dpi 120

xsetroot -cursor_name left_ptr -solid royalblue

# all other programs run from i3 config

exec i3
