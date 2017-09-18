set -gx fish_greeting ''

# Python
if test -x /usr/local/bin/python3
  eval (/usr/local/bin/python3 -m virtualfish)
else if test -x /usr/bin/python3
  eval (/usr/bin/python3 -m virtualfish)
end

set -g __fish_git_prompt_showdirtystate 1
# set -g fish_prompt_pwd_dir_length 2

# useful:
#  https://wiki.archlinux.org/index.php/GnuPG
#  https://github.com/gpg/gnupg/tree/master/doc/examples/systemd-user
if command -s gpg-connect-agent >/dev/null
  # compatibility with OSX, replace OSX Keychain SSH helper with GPG
  if [ (uname -s) = Darwin ]
    set -x SSH_AUTH_SOCK (gpgconf --list-dirs agent-ssh-socket)
  end
  # get curses pinentry's in the right place
  set -x GPG_TTY (tty)
  gpg-connect-agent updatestartuptty /bye >/dev/null
end

# iTerm2 shell integration
# https://iterm2.com/documentation-shell-integration.html
source "$HOME/.config/fish/iterm2_startup.fish"

eval (python -m virtualfish auto_activation)
