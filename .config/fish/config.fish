set -gx fish_greeting ''

# Python
if test -x /usr/local/bin/python3
  eval (/usr/local/bin/python3 -m virtualfish)
else if test -x /usr/bin/python3
  eval (/usr/bin/python3 -m virtualfish)
end

# for GPG Agent
set -x GPG_TTY (tty)
# Refresh gpg-agent tty in case user switches into an X session
gpg-connect-agent updatestartuptty /bye >/dev/null

# iTerm2 shell integration
# https://iterm2.com/documentation-shell-integration.html
source "$HOME/.config/fish/iterm2_startup.fish"
