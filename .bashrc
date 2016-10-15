#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

for fish in /usr/bin/fish /usr/local/bin/fish; do
    if [ -x "$fish" ]; then
	exec "$fish"
    fi
done

alias ls='ls --color=auto'
PS1='[\u@\h \W]\$ '
