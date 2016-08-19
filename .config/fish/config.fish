set -gx fish_greeting ''

set -gx PATH ~/bin ~/.npm-packages/bin $PATH

if command --search src-hilite-lesspipe.sh > /dev/null
  set -gx LESSOPEN "| src-hilite-lesspipe.sh %s"
  set -gx LESS "-R"
end

set -gx PIP_REQUIRE_VIRTUALENV true
eval (/usr/local/bin/python3 -m virtualfish)
