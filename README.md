# usage

see [harfangk bare dotfiles][] for some more info, but the basic idea
is to clone the appropriate repo into a "bare" repository:

``` sh
git clone --bare github.com:smason/dotfiles ~/.dotfiles --branch wayland
git --dir-dir ~/.dotfiles --work-tree ~ checkout
```

this should include a special script called `config` (in `.local/bin`)
to invoke `git` with the appropriate flags to make invoking the above
easy.  I'd suggest using it immediately by doing:

``` sh
config config --local status.showUntrackedFiles no
```

to prevent git from telling you that everything needs to be added.
later on you can commit changes with:

``` sh
config add -p
config commit
```

# repos

 * `wayland` is current; Linux with Wayland for graphics
 * `xorg` is my older X11 based setup
 * `osx` has some Apple stuff

[harfangk bare dotfiles]: https://harfangk.github.io/2016/09/18/manage-dotfiles-with-a-git-bare-repository.html
