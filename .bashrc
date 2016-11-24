# If not running interactively, don't do anything
[[ $- != *i* ]] && return

for fish in /usr/bin/fish /usr/local/bin/fish; do
    test -x "$fish" && exec "$fish"
done
