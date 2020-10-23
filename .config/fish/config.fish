if test -d ~/.local/bin
    set -x PATH ~/.local/bin $PATH
end

if test -d ~/.cargo/bin
    set -x PATH ~/.cargo/bin $PATH
end

# nice, but too slow on large repos!
# set __fish_git_prompt_showdirtystate yes

# Python
set -x PIP_REQUIRE_VIRTUALENV true

# GPG
if command -s gpg-connect-agent >/dev/null
    set -x GPG_TTY (tty)
    set -x SSH_AUTH_SOCK (gpgconf --list-dirs agent-ssh-socket)
    gpg-connect-agent -q updatestartuptty /bye >/dev/null
end
