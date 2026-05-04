
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
    pkgs.rio
    pkgs.keepassxc
    pkgs.waypipe

    # can't install lact because it has a root service
    pkgs.vkmark
    pkgs.vulkan-tools

    # Using Niri seems awkward due to qml-niri

    # python
    pkgs.uv

    # utilities
    pkgs.rink
    pkgs.tmux
    pkgs.aria2
    pkgs.imv
    pkgs.wev
    pkgs.ripgrep
    pkgs.tio
    pkgs.webfs # simple http server

    # system tools
    pkgs.perf
    pkgs.strace
    pkgs.sysstat
    pkgs.nvtopPackages.amd
    pkgs.linuxKernel.packages.linux_7_0.turbostat
    pkgs.netcat-openbsd
    pkgs.nmap

    # archives
    pkgs.p7zip
    # not much point getting these via Nix, lots of Arch packages need them so
    # they'll already be on the system
    pkgs.xz
    pkgs.zstd
    pkgs.gzip

    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

    (pkgs.writeShellScriptBin "helix" ''exec hx "$@"'')
    (pkgs.writeShellScriptBin "webfs-cwd" ''
      xdg-open http://localhost:8080/
      exec webfsd -Fp 8080 -l-'')
  ];

  services.gpg-agent = {
    enable = true;
    enableSshSupport = true;
    defaultCacheTtl = 60;
    pinentry = {
      package = pkgs.pinentry-qt;
    };
  };

  programs.gpg = {
    enable = true;

    settings = {
      personal-cipher-preferences = "AES256 AES192 AES";
      personal-digest-preferences = "SHA512 SHA384 SHA256";
      personal-compress-preferences = "ZLIB BZIP2 ZIP Uncompressed";
      default-preference-list = "SHA512 SHA384 SHA256 AES256 AES192 AES ZLIB BZIP2 ZIP Uncompressed";
      cert-digest-algo = "SHA512";
      s2k-digest-algo = "SHA512";
      s2k-cipher-algo = "AES256";
      charset = "utf-8";
      fixed-list-mode = "";
      no-comments = "";
      no-emit-version = "";
      no-greeting = "";
      keyid-format = "0xlong";
      list-options = "show-uid-validity";
      verify-options = "show-uid-validity";
      with-fingerprint = "";
      require-cross-certification = "";
      no-symkey-cache = "";
      throw-keyids = "";
      use-agent = "";

      keyserver = "hkps://keyserver.ubuntu.com";
    };
  };

  programs.helix = {
    enable = true;
    defaultEditor = true;

    extraPackages = [
      # text editing
      pkgs.harper
      pkgs.marksman
      pkgs.markdown-oxide
      pkgs.tinymist

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
