set -gx fish_greeting ''

# various path changes
if [ -d "$HOME/android-sdk" ]
  set -gx ANDROID_HOME "$HOME/android-sdk"
  set -gx PATH "$ANDROID_HOME/tools" "$ANDROID_HOME/platform-tools" $PATH
end

# node
if [ -d "$HOME/.npm-packages" ]
   set -gx PATH "$HOME/.npm-packages/bin" $PATH
end

if [ -d "$HOME/bin" ]
   set -gx PATH "$HOME/bin" $PATH
end

if command --search src-hilite-lesspipe.sh > /dev/null
  set -gx LESSOPEN "| src-hilite-lesspipe.sh %s"
  set -gx LESS "-R"
end

set -gx PIP_REQUIRE_VIRTUALENV true
eval (/usr/local/bin/python3 -m virtualfish)
