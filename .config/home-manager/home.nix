
# useful commands to remember:
#   nix-channel --update
#   home-manager switch
#   nix-store --gc

{ config, pkgs, ... }:
{
  home.username = "smason";
  home.homeDirectory = "/home/smason";

  home.stateVersion = "26.05"; # NOTE: Check release notes before changing!!!

  home.packages = [
    # GUI programs
    pkgs.ghostty

    # Python
    pkgs.uv

    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

    (pkgs.writeShellScriptBin "helix" ''exec hx "$@"'')
  ];

  programs.helix = {
    enable = true;
    defaultEditor = true;

    extraPackages = [
      # text editing
      pkgs.harper
      pkgs.marksman
      pkgs.markdown-oxide

      # Python stuff
      pkgs.ty
      pkgs.ruff
    ];
  };

  programs.mpv = {
    enable = true;

    scripts = [
      pkgs.mpvScripts.builtins.autocrop
      pkgs.mpvScripts.mpris
    ];
  };

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. These will be explicitly sourced when using a
  # shell provided by Home Manager. If you don't want to manage your shell
  # through Home Manager then you have to manually source 'hm-session-vars.sh'
  # located at either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/smason/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    EDITOR = "hx";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # see https://nix-community.github.io/home-manager/index.xhtml#sec-usage-gpu-sudo
  # need to run sudo /nix/store/*-non-nixos-gpu/bin/non-nixos-gpu-setup
  targets.genericLinux.enable = true;
}
