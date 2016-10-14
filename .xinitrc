#!/bin/sh

[ -f ~/.Xresources ] && xrdb ~/.Xresources
[ -f ~/.Xmodmap ] && xmodmap ~/.Xmodmap

# disable capslock
xkbset nullify lock

# set screen resolution nicely
xrandr --dpi 120

# all other programs run from i3 config

exec i3
