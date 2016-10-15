#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

FISH=/usr/bin/fish
[ -x "$FISH" ] && exec "$FISH"

alias ls='ls --color=auto'
PS1='[\u@\h \W]\$ '
