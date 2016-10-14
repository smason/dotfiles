#
# ~/.bash_profile
#

FISH=/usr/local/bin/fish
[ -x "$FISH" ] && exec "$FISH"

[[ -f ~/.bashrc ]] && . ~/.bashrc
