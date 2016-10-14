#!/bin/sh

[ -f ~/.Xresources ] && xrdb ~/.Xresources
[ -f ~/.Xmodmap ] && xmodmap ~/.Xmodmap

xrandr --dpi 120

# all other programs run from i3 config

exec i3
