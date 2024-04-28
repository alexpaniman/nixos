# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ self, system, config, lib, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Enable nix ld
  programs.nix-ld.enable = true;

  # Sets up all the libraries to load
  programs.nix-ld.libraries = with pkgs; [
    stdenv.cc.cc
    zlib
    fuse3
    icu
    zlib
    nss
    openssl
    curl
    expat
    # ...
  ];

  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "nodev";
  # boot.loader.grub.useOSProber = true;
  # boot.loader.grub.fsIndentifier = "lable";
  boot.loader.grub.efiSupport = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.grub.extraConfig = ''
    GRUB_TIMEOUT=2
    GRUB_TIMEOUT_STYLE="hidden"
  '';

  
  boot.kernelParams = [ "fbcon=rotate:1" ];


  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  environment.sessionVariables = {
    WLR_NO_HARDWARE_CURSORS = "1";
    NIXOS_OZON_WL = "1";
  };

  programs.sway.enable = true;

  # Make some extra kernel modules available to NixOS
  boot.extraModulePackages = with config.boot.kernelPackages;
    [ v4l2loopback.out ];

  # Activate kernel modules (choose from built-ins and extra ones)
  boot.kernelModules = [
    # Virtual Camera
    "v4l2loopback"
    # Virtual Microphone, built-in
    "snd-aloop"
    "kvm-intel"
  ];

  # Set initial kernel module settings
  boot.extraModprobeConfig = ''
    # exclusive_caps: Skype, Zoom, Teams etc. will only show device when actually streaming
    # card_label: Name of virtual camera, how it'll show up in Skype, Zoom, Teams
    # https://github.com/umlaeute/v4l2loopback
    options v4l2loopback exclusive_caps=1 card_label="Virtual Camera"
  '';

  services.udev.extraRules = ''
    KERNEL=="hidraw*", SUBSYSTEM=="hidraw", MODE="0660", GROUP="users", TAG+="uaccess", TAG+="udev-acl"
  '';


  networking.hostName = "pcniman"; # Define your hostname.
  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

  # Set your time zone.
  time.timeZone = "Europe/Moscow";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  # i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkb.options in tty.
  # };

  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
  };

  services.xserver = {
    enable = true;
    autorun = true;

    xkb.layout = "us,ru";
    xkb.model = "pc105";
    xkb.options = "grp:menu_toggle";

    autoRepeatDelay = 300;
    autoRepeatInterval = 20;

    videoDrivers = [ "nvidia" ];
    windowManager = {
      xmonad = {
        enable = true;
        enableContribAndExtras = true;
      };
    }; 
    displayManager = {
      lightdm = {
        enable = true;
        greeters.enso = {
          enable = true;
          blur = true;
        };
      };
      sessionCommands = ''
        ./.screenlayout/current.sh
        nitrogen --restore
      '';
    };
  };

  services.displayManager = {
    defaultSession = "none+xmonad";
  };

  hardware.nvidia = {
    modesetting.enable = true;
    nvidiaSettings = true;
    open = false; # I'm gonna give them a bit more time
    package = config.boot.kernelPackages.nvidiaPackages.beta;
  };


  # Disable pulseaudio
  sound.enable = false;
  hardware.pulseaudio.enable = false;

  # Enable pipewire instead
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa = {
      enable = true;
      support32Bit = true;
    };
    pulse.enable = true;
    jack.enable = true;
    wireplumber.enable = true;
  };

  users.users.alex = {
    isNormalUser = true;
    extraGroups = [ "wheel" "audio" ]; # Enable ‘sudo’ for the user.
    packages = with pkgs; [];
  };

  environment.systemPackages = with pkgs; [
    # The one and only
    emacs

    # Shell
    vim # i need a way to fix emacs without... emacs 
    alacritty
    nushell
    zsh

    # Basic graphical programs
    firefox
    brave
    transmission-gtk

    # Sound
    pavucontrol
    pulseaudio

    # Conferencing
    xournalpp
    obs-studio
    zoom-us

    # Messaging
    telegram-desktop

    # Images
    imagemagick
    sxiv
    inkscape
    krita

    # Videos
    mpv

    # Documents
    texlive.combined.scheme-full
    onlyoffice-bin
    zathura
    sioyek

    # Graphical environment
    rofi 
    picom
    nitrogen

    # System tools
    tty-clock
    ncdu
    fastfetch
    btop
    nvitop
    screenkey
    pv

    man-pages
    man-pages-posix

    # Main infrastructure programs
    git 
    git-lfs

    # Basic cmdline tools
    killall
    wget
    unzip
    unrar

    # Development
    jdk
    stack

    gcc
    clang
    clang-tools
    cmake
    ninja
    gnumake

    python3

    jetbrains.idea-community

    # Nix tools
    manix

    home-manager

    comma
    steam-run	

    direnv
    cached-nix-shell

    any-nix-shell

    # Games
    lutris

    # Theming
    fluent-gtk-theme

    # Screenshots
    flameshot
    maim
    xclip

    # Keyboard
    vial

    # VPN
    openvpn
    update-systemd-resolved

    gdb
    sage

    # Modelling
    blender

    # Nix ld tools
    self.inputs.nix-alien.packages.${system}.nix-alien

    (let
      my_mathematica = mathematica.override {
        version = "13.2.1";
        source = pkgs.requireFile {
          name = "Mathematica_13.2.1_LINUX.sh";
          # Get this hash via a command similar to this:
          # nix-store --query --hash \
          # $(nix store add-path Mathematica_XX.X.X_BNDL_LINUX.sh --name 'Mathematica_XX.X.X_BNDL_LINUX.sh')
          sha256 = "1661ra9c9lidswp9f2nps7iz9kq7fsgxd0x6kl7lv4d142fwkhdk";
          message = ''
            Your override for Mathematica includes a different src for the installer,
            and it is missing.
          '';
          hashMode = "recursive";
        };
      };
    in my_mathematica)
  ];

  services.resolved = {
    enable = true;
  };


  documentation.dev.enable = true;


  environment.etc = {
    "xdg/user-dirs.defaults".text = ''
        DESKTOP=desktop
        DOWNLOAD=downloads
        TEMPLATES=templates
        PUBLICSHARE=public
        DOCUMENTS=documents
        MUSIC=music
        PICTURES=pictures
        VIDEOS=videos
    '';
  };

  environment.sessionVariables = {
    XDG_DESKTOP_DIR="$HOME/desktop";
    XDG_DOCUMENTS_DIR="$HOME/documents";
    XDG_DOWNLOAD_DIR="$HOME/downloads";
    XDG_MUSIC_DIR="$HOME/music";
    XDG_PICTURES_DIR="$HOME/pictures";
    XDG_PUBLICSHARE_DIR="$HOME/public";
    XDG_TEMPLATES_DIR="$HOME/templates";
    XDG_VIDEOS_DIR="$HOME/video";
  };


  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk
    noto-fonts-emoji
    jetbrains-mono
    fira-code
    fira-code-symbols
    fira
    iosevka-comfy.comfy-motion
    cascadia-code
  ];

  services.xserver.xrandrHeads = [
    {
      output = "DP-0";
      primary = true;
    }
  
    {
      output = "DP-2";
      monitorConfig = "Option \"Rotate\" \"right\"";
    }
  ];

  programs.zsh.enable = true;
  users.users.alex.shell = pkgs.zsh;

  # Open all the ports by disabling the firewall altogether
  networking.firewall.enable = false;


  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "23.11"; # Did you read the comment?

}

