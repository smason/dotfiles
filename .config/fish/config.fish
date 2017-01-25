set -gx fish_greeting ''

# Python
if test -x /usr/local/bin/python3
  eval (/usr/local/bin/python3 -m virtualfish)
else if test -x /usr/bin/python3
  eval (/usr/bin/python3 -m virtualfish)
end

set -x __fish_git_prompt_showdirtystate 1

# useful:
#  https://wiki.archlinux.org/index.php/GnuPG
#  https://github.com/gpg/gnupg/tree/master/doc/examples/systemd-user
if command -s gpg-connect-agent >/dev/null
  # compatibility with OSX
  set -l SSH_AUTH_SOCK "$HOME/.gnupg/S.gpg-agent.ssh"
  if [ -S "$SSH_AUTH_SOCK" ]
    set -x SSH_AUTH_SOCK
  end
  # get curses pinentry's in the right place
  set -x GPG_TTY (tty)
  gpg-connect-agent updatestartuptty /bye >/dev/null
end

# iTerm2 shell integration
# https://iterm2.com/documentation-shell-integration.html
source "$HOME/.config/fish/iterm2_startup.fish"
