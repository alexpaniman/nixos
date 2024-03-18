{ config, pkgs, ... }:

rec {
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "alex";
  home.homeDirectory = "/home/alex";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "23.11"; # Please read the comment before changing.

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = [
    # # Adds the 'hello' command to your environment. It prints a friendly
    # # "Hello, world!" when run.
    # pkgs.hello

    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
  ];

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
  # 'home.sessionVariables'. If you don't want to manage your shell through Home
  # Manager then you have to manually source 'hm-session-vars.sh' located at
  # either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/alex/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    EDITOR = "vim";
  };

  programs.git = {
    enable = true;
    userName = "alexpaniman";
    userEmail = "alexpaniman@gmail.com";
  };

  programs.zsh = {
    enable = true;

    autosuggestion.enable = true;

    enableCompletion = true;
    syntaxHighlighting.enable = true;

    initExtra = ''
      bindkey '^H' backward-kill-word
      bindkey '5~' kill-word
      source ${pkgs.nix-index}/etc/profile.d/command-not-found.sh
      any-nix-shell zsh --info-right | source /dev/stdin
    '';

    shellAliases = 
      let
        nixos-dir      = "~/nixos";
        nixos-home-dir = "${nixos-dir}/home";
        nixos-conf-dir = "${nixos-dir}/conf";

        make-nixos-commit-cmd =
          msg: "(cd ${nixos-dir}; git add . && git commit -m '${msg}' && git push) || true";
      in
      {
        # nixos updating & upgrading aliases
        push-nixos-generation = (make-nixos-commit-cmd "update: automatic generation save");
        push-nixos-bumps = (make-nixos-commit-cmd "update: automatic flake.lock version bumps");

        update-home = "(cd ${nixos-home-dir}; nix flake update)";
        update-conf = "(cd ${nixos-conf-dir}; nix flake update)";
        update      = "push-nixos-generation && update-conf && update-home && push-nixos-bumps";

        upgrade-home = "home-manager switch --flake ${nixos-home-dir}#${home.username}";
        upgrade-conf = "sudo nixos-rebuild switch --flake ${nixos-conf-dir}#default";
        upgrade = "upgrade-home && upgrade-conf";

        upd = "update && upgrade";

        # navigation
        ls = "${pkgs.eza}/bin/eza";

        ff = ''cd "''$(${pkgs.fd}/bin/fd | ${pkgs.fzf}/bin/fzf | xargs dirname)"'';
        fh = ''cd ~ && ff'';
      };

    history.size = 1000000;
    history.path = "${config.xdg.dataHome}/zsh/history";

    oh-my-zsh = {
      enable = true;
      plugins = [ "git" ];
      theme = "robbyrussell";
    };
  };

  programs.direnv = {
    enable = true;
    enableZshIntegration = true;

    nix-direnv.enable = true;
  };

  programs.command-not-found.enable = false;

  programs.emacs = {
    enable = true;
    package = pkgs.emacs;
  };

  programs.alacritty = {
    enable = true;

    settings = {
      window.padding = { x = 4; y = 4; };
      keyboard.bindings = [{
        key = "Return";
        mods = "Control|Shift";
        chars = "SpawnNewInstance";
      }];
    };
  };




  xdg.configFile = {
    "emacs" = {
        source = builtins.fetchGit {
          url = "https://github.com/alexpaniman/panimacs";
          rev = "26e285c673037579f0e52a96125920c0aa06e4a9";
        };
        recursive = true;
    };
  };

  services.picom = {
    enable = true;
    backend = "glx";
    activeOpacity = 1;
    settings = {
      blur = true;

      animations = true;
      animation-stiffness = 300.0;
      animation-dampening = 35.0;
      animation-clamping = false;
      animation-mass = 1;
      animation-for-workspace-switch-in = "auto";
      animation-for-workspace-switch-out = "auto";
      animation-for-open-window = "slide-down";
      animation-for-menu-window = "none";
      animation-for-transient-window = "slide-down";

      corner-radius = 12;

      blur-method = "dual_kawase";
      blur-strength = "10";
      xinerama-shadow-crop = true;
    };

    vSync = true;
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
