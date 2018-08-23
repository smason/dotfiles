#!/bin/sh

setxkbmap -model dell101 \
	  -layout gb \
	  -option ctrl:nocaps \
	  -option terminate:ctrl_alt_bksp \
	  -option compose:ralt

[ -f ~/.Xresources ] && xrdb ~/.Xresources

# disable capslock
xkbset nullify lock

# set screen resolution nicely
xrandr --dpi 110 \
    --output DP-0   --auto --pos 0x0 --primary \
    --output HDMI-0 --auto --pos 3840x100

compton --config ~/.config/compton/compton.conf -b

xsetroot -cursor_name left_ptr -solid royalblue

# all other programs run from i3 config
exec i3 2>&1 > ~/log/i3.log
