export PAGER=less

# various path changes
if [ -d "$HOME/android-sdk" ]; then
  export ANDROID_HOME="$HOME/android-sdk"
  export PATH="$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools:$PATH"
fi

# node
if [ -d "$HOME/.npm-packages" ]; then
   export PATH="$HOME/.npm-packages/bin:$PATH"
fi

# final fiddling with path
if [ -d "$HOME/bin" ]; then
   export PATH="$HOME/bin:$PATH"
fi

# Less config
if which src-hilite-lesspipe.sh >/dev/null 2>&1; then
  export LESSOPEN="| src-hilite-lesspipe.sh %s"
  export LESS="-R"
fi

# Python
export PIP_REQUIRE_VIRTUALENV=true
