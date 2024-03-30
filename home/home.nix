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
    # Useful cli tools
    pkgs.fd
    pkgs.ripgrep
    pkgs.fzf

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

        e = "emacsclient --create-frame --no-wait --alternate-editor=''";
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
      window.opacity = 0.9;

      keyboard.bindings = [{
        key = "Return";
        mods = "Control|Shift";
        action = "SpawnNewInstance";
      }];

      colors = {
        primary = {
            background = "0x1c1d20";
            foreground = "0xfff1f3";
        };

        normal = {
            black      = "0x2c2525";
            red        = "0xfd6883";
            green      = "0xadda78";
            yellow     = "0xf9cc6c";
            blue       = "0xf38d70";
            magenta    = "0xa8a9eb";
            cyan       = "0x85dacc";
            white      = "0xfff1f3";
        };

        bright = {
            black      = "0x72696a";
            red        = "0xfd6883";
            green      = "0xadda78";
            yellow     = "0xf9cc6c";
            blue       = "0xf38d70";
            magenta    = "0xa8a9eb";
            cyan       = "0x85dacc";
            white      = "0xfff1f3";
        };
      };
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

  home.pointerCursor = 
    let 
      getFrom = url: hash: name: {
          gtk.enable = true;
          x11.enable = true;
          name = name;
          size = 48;
          package = 
            pkgs.runCommand "moveUp" {} ''
              mkdir -p $out/share/icons
              ln -s ${pkgs.fetchzip {
                url = url;
                hash = hash;
              }} $out/share/icons/${name}
          '';
        };
    in
      getFrom 
        "https://github.com/ful1e5/fuchsia-cursor/releases/download/v2.0.0/Fuchsia-Pop.tar.gz"
        "sha256-BvVE9qupMjw7JRqFUj1J0a4ys6kc9fOLBPx2bGaapTk="
        "Fuchsia-Pop";


  services.picom = {
    enable = true;
    backend = "glx";

    settings = {
      corner-radius = 5;

      blur = true;
      blur-method = "dual_kawase";
      blur-strength = "10";

      # Picom developers did the stupidest thing ever by adding a rule to EXclude things from background blur,
      # but not to INclude windows for background blur. So it goes like that: you enable blur and for some
      # time everything seems fine, until you launch, let's say, a screenshoter, that now blurs your whole
      # entire screen and you can't see anything, which is quite important for taking screenshots..

      # And yeah, it's picom's doing. How to get around it? Add this window's class to blur-background-exclude!
      # That's what I did too and it works... until you meet another window, menu, dialog, etc... that doesn't
      # place nice with blur, and who would have thought, it's so common to use blur on everything, right??

      # Much smarter thing would be to add JUST the things I want to blur: for me it's just the terminal, nothing
      # else... But I found now way to do this in the documentation! What to do then, keep playing this game of
      # looking up window type of everything with xprop and adding, adding, adding it to the list? I refuse!!

      # Instead, I thought, I will just write a regex to match EVERYTHING EXCEPT the terminal, but what do you
      # know, picom doesn't support negative lookahead, aha, and here I thought I was onto something!

      # Still I don't give up that easily and instead just made a regex that matches every string that does not
      # contain class name of my terminal "Alacritty", and, yeah, it's hella long, but, at least, it works.

      # NOTE: for future me or other readers, I didn't actually write this by hand and instead used a website:
      #       that did it for me: http://www.formauri.es/personal/pgimeno/misc/non-match-regex/?word=Alacritty
      #       (I sincerely hope that it's not down at your time, future reader, if it is -- I'm sorry, you
      #        try to find it or similar service by typing "extended regular expression that matches a string
      #        that does not contain given word", that is if you still have search engines in the future)

      blur-background-exclude = [
        "class_g ~= '^([^A]|A(A|l(A|a(A|c(A|r(A|i(A|t(A|tA)))))))*([^Al]|l([^Aa]|a([^Ac]|c([^Ar]|r([^Ai]|i([^At]|t([^At]|t[^Ay]))))))))*(A(A|l(A|a(A|c(A|r(A|i(A|t(A|tA)))))))*(l(a?|ac(r?|ri(t?|tt))))?)?$'"
      ];
    };

    vSync = true;
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
