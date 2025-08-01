{ config, pkgs, panimacs, ... }:

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

    pkgs.libnotify

    pkgs.mindustry
    pkgs.emacs-lsp-booster

    pkgs.fira-code-nerdfont
    pkgs.htop

    # # Adds the 'hello' command to your environment. It prints a friendly
    # # "Hello, world!" when run.
    # pkgs.hello

    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })
    pkgs.corefonts
    pkgs.vistafonts

    (pkgs.writeShellScriptBin "xdg-open-emacs" ''
        target_file="$(readlink -f "$1")"
        emacsclient --eval "(panimacs/xdg-open \"$target_file\")"
    '')

    panimacs.packages."${pkgs.system}".default
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

    extraConfig = {
      oh-my-zsh.hide-dirty = 1;
    };
  };

  programs.zsh = {
    enable = true;

    autosuggestion.enable = true;

    enableCompletion = true;
    syntaxHighlighting.enable = true;

    initExtraFirst = ''
      [[ $TERM == "dumb" ]] && unsetopt zle && PS1='$ ' && return 
    '';

    initExtra = ''
      bindkey '^H' backward-kill-word
      bindkey '5~' kill-word

      source ${pkgs.nix-index}/etc/profile.d/command-not-found.sh
      any-nix-shell zsh --info-right | source /dev/stdin

      export DISABLE_MAGIC_FUNCTIONS=true
      export ZSH_AUTOSUGGEST_MANUAL_REBIND=1

      ff() {
        target_directory="''$(${pkgs.fd}/bin/fd --hidden '.*' "''${1:-.}" | ${pkgs.fzf}/bin/fzf | xargs dirname 2>/dev/null)"
        if [[ $? -eq 0 ]]; then
           cd "$target_directory"
        fi
      }

      # if [[ $- == *i* ]] || [[ "$INSIDE_EMACS" =~ 'vterm' ]]; then
      #     source $ZSH/oh-my-zsh.sh
      # fi

      # Fix for emacs tramp
      if [[ "$TERM" == "dumb" ]]; then
          unsetopt zle
          PS1='> '
          HISTFILE=~/.tramp-histfile
      fi

      vterm_printf() {
          if [ -n "$TMUX" ] && ([ "''${TERM%%-*}" = "tmux" ] || [ "''${TERM%%-*}" = "screen" ]); then
              # Tell tmux to pass the escape sequences through
              printf "\ePtmux;\e\e]%s\007\e\\" "$1"
          elif [ "''${TERM%%-*}" = "screen" ]; then
              # GNU screen (screen, screen-256color, screen-256color-bce)
              printf "\eP\e]%s\007\e\\" "$1"
          else
              printf "\e]%s\e\\" "$1"
          fi
      }

      vterm_prompt_end() {
          vterm_printf "51;A$(whoami)@$(hostname):$(pwd)"
      }

      if [[ "$INSIDE_EMACS" =~ 'vterm' ]]; then
          alias clear='vterm_printf "51;Evterm-clear-scrollback";tput clear'

          setopt PROMPT_SUBST
          PROMPT=$PROMPT'%{$(vterm_prompt_end)%}'
      fi

      export PS1="%{$fg_bold[cyan]%}[%n@%m] %c%{$reset_color%} \$(git_prompt_info)%(?:%{$fg_bold[green]%}%1{$%}:%{$fg_bold[red]%}%1{$%})%{$reset_color%} "
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

        fh = ''ff ~'';
        fs = ''ff /'';

        e = "panimacsclient -nw -a '' -c";
        ew = "panimacsclient --create-frame --no-wait --alternate-editor=''";
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

  programs.emacs =
    let
      my-emacs = pkgs.emacs.override {
        withNativeCompilation = true;
        withSQLite3 = true;
        withTreeSitter = true;
        withWebP = true;
      };
      # my-emacs = (pkgs.emacs.override {
      #   withNativeCompilation = true;
      #   withSQLite3 = true;
      #   withTreeSitter = true;
      #   withWebP = true;
      # }).overrideAttrs (old: {
      #   version = "commercial-emacs-git";
      #   src = pkgs.fetchFromGitHub {
      #     owner = "commercial-emacs";
      #     repo = "commercial-emacs";
      #     rev = "a98e5518a76d336dda16e0c8e622950ba2efb5c8";
      #     sha256 = "sha256-yAnotska4K0128l8WI5dAbGNqran6yGPR0AHeYMlG+M=";
      #   };
      # });
      my-emacs-with-packages = (pkgs.emacsPackagesFor my-emacs).emacsWithPackages (epkgs: with epkgs; [
        vterm
        multi-vterm
        pdf-tools
        treesit-grammars.with-all-grammars
      ]);
    in
    {
      enable = true;
      package = my-emacs-with-packages;
    };

  programs.alacritty = {
    enable = true;

    settings = {
      font = {
        normal = {
          family = "Cascadia Code";
        };
      };

      window.padding = { x = 4; y = 4; };
      window.opacity = 0.9;

      keyboard.bindings = [{
        key = "Return";
        mods = "Control|Shift";
        action = "SpawnNewInstance";
      }];

      colors = {
#        primary = {
#          background = "#eff1f5";
#          foreground = "#4c4f69";
#          dim_foreground = "#8c8fa1";
#          bright_foreground = "#4c4f69";
#        };
#
#        cursor = {
#          text = "#eff1f5";
#          cursor = "#dc8a78";
#        };
#
#        vi_mode_cursor = {
#          text = "#eff1f5";
#          cursor = "#7287fd";
#        };
#
#        search.matches = {
#          foreground = "#eff1f5";
#          background = "#6c6f85";
#        };
#
#        search.focused_match = {
#          foreground = "#eff1f5";
#          background = "#40a02b";
#        };
#
#        footer_bar = {
#          foreground = "#eff1f5";
#          background = "#6c6f85";
#        };
#
#        hints.end = {
#          foreground = "#eff1f5";
#          background = "#df8e1d";
#        };
#
#        selection = {
#          text = "#eff1f5";
#          background = "#dc8a78";
#        };
#
#        normal = {
#          black = "#bcc0cc";
#          red = "#d20f39";
#          green = "#40a02b";
#          yellow = "#df8e1d";
#          blue = "#1e66f5";
#          magenta = "#ea76cb";
#          cyan = "#179299";
#          white = "#5c5f77";
#        };
        #
        #        bright = {
        #          black = "#acb0be";
        #          red = "#d20f39";
        #          green = "#40a02b";
        #          yellow = "#df8e1d";
        #          blue = "#1e66f5";
        #          magenta = "#ea76cb";
        #          cyan = "#179299";
        #          white = "#6c6f85";
        #        };

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
          rev = "110ed41d0ae507c4a83afb271ee43b931ba51c06";
        };
        recursive = true;
    };
  };

  services.picom = {
    enable = true;
    backend = "glx";

    settings = {
      corner-radius = 5;

      blur = true;
      blur-method = "dual_kawase";
      blur-strength = "10";

      blur-background-exclude = [
        "!(class_g ~= '^Alacritty$')"
      ];
    };

    vSync = true;
  };

  services.dunst = {
    enable = true;

    settings = {
      global = {
        frame_width = 1;
        frame_color = "#f91c81ff";
        background = "#1c1d20ff";
        foreground = "#b6b7bcff";
        timeout = 1;
      };
    };
  };

  xdg.desktopEntries = {
    emacs = {
      name = "Emacs (XDG-Open)";
      genericName = "Text Editor";
      exec = "xdg-open-emacs %F";
      terminal = false;
      categories = [ "Development" "TextEditor" ];
      icon = "emacs";
      mimeType = [
        "text/english"
        "text/plain"
        "text/x-makefile"
        "text/x-c++hdr"
        "text/x-c++src"
        "text/x-chdr"
        "text/x-csrc"
        "text/x-java"
        "text/x-moc"
        "text/x-pascal"
        "text/x-tcl"
        "text/x-tex"
        "application/x-shellscript"
        "text/x-c"
        "text/x-c++"
      ];
    };
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  dconf.enable = true;
  dconf.settings = {
    "org/gnome/desktop/background" = {
      picture-uri-dark = "file://${pkgs.nixos-artwork.wallpapers.nineish-dark-gray.src}";
    };
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
    };
  };

  gtk = {
    enable = true;
    theme = {
      name = "Fluent-Dark-compact";
      package = pkgs.fluent-gtk-theme;
    };
  };

}
