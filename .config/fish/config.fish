set -gx fish_greeting ''

# Python
if test -x /usr/local/bin/python3
  eval (/usr/local/bin/python3 -m virtualfish)
else if test -x /usr/bin/python3
  eval (/usr/bin/python3 -m virtualfish)
end

set -x __fish_git_prompt_showdirtystate 1

# Refresh gpg-agent tty in case user switches into an X session
if command -s gpg-connect-agent >/dev/null
  set -l SSH_AUTH_SOCK "$HOME/.gnupg/S.gpg-agent.ssh"
  if [ -f "$SSH_AUTH_SOCK" ]
    set -x SSH_AUTH_SOCK
  end
  set -x GPG_TTY (tty)
  gpg-connect-agent updatestartuptty /bye >/dev/null
end

# iTerm2 shell integration
# https://iterm2.com/documentation-shell-integration.html
source "$HOME/.config/fish/iterm2_startup.fish"
