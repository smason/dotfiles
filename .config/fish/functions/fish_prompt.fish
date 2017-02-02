function fish_prompt --description 'Write out the prompt'
    # Just calculate this once, to save a few cycles when displaying the prompt
    if not set -q __fish_prompt_hostname
        set -g __fish_prompt_hostname (hostname|cut -d . -f 1)
    end

    set -l color_cwd
    set -l suffix
    switch $USER
      case root toor
        set color_cwd red
        set suffix ' # '
      case '*'
        set color_cwd green
        set suffix ' » '
    end

    set -l git_status (set_color cyan)(__fish_git_prompt '[%s] ')

    set -l virtualfish
    if set -q VIRTUAL_ENV
      set virtualfish (set_color magenta)(basename "$VIRTUAL_ENV ")
    end

    # "$USER@$__fish_prompt_hostname "
    echo -n -s "$__fish_prompt_hostname " $virtualfish $git_status (set_color $color_cwd) (prompt_pwd) $suffix (set_color normal)
end
