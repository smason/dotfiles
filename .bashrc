# If not running interactively, don't do anything
[[ $- != *i* ]] && return

case "$TERM" in
dumb)
    PS1="> "
    return
    ;;
rxvt-unicode-256color)
    # TERM=xterm
    ;;
esac

for fish in /usr/bin/fish /usr/local/bin/fish; do
    test -x "$fish" && exec "$fish"
done
