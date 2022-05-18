function vf --argument name
    source "$HOME/.local/venvs/$name/bin/activate.fish"
end

complete -c vf -rfa "(ls -1 $HOME/.local/venvs)"
