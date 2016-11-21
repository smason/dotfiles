set -gx fish_greeting ''

set -gx PAGER less

# various path changes
if [ -d "$HOME/android-sdk" ]
  set -gx ANDROID_HOME "$HOME/android-sdk"
  set -gx PATH "$ANDROID_HOME/tools" "$ANDROID_HOME/platform-tools" $PATH
end

# node
if [ -d "$HOME/.npm-packages" ]
   set -gx PATH "$HOME/.npm-packages/bin" $PATH
end

# final fiddling with path
if [ -d "$HOME/bin" ]
   set -gx PATH "$HOME/bin" $PATH
end

# Less config
if command --search src-hilite-lesspipe.sh > /dev/null
  set -gx LESSOPEN "| src-hilite-lesspipe.sh %s"
  set -gx LESS "-R"
end

# Python
set -gx PIP_REQUIRE_VIRTUALENV true
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
