# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
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
      defaultSession = "none+xmonad";
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

  hardware.nvidia = {
    modesetting.enable = true;
    nvidiaSettings = true;
    open = false; # I'm gonna give them a bit more time
    package = config.boot.kernelPackages.nvidiaPackages.beta;
  };


  # Enable sound.
  sound.enable = false;
  hardware.pulseaudio.enable = false;

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

  # hardware.pipewire.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.alex = {
    isNormalUser = true;
    extraGroups = [ "wheel" "audio" ]; # Enable ‘sudo’ for the user.
    packages = with pkgs; [];
  };

  # pkgs.btop = pkgs.btop.overrideAttrs (oldAttrs: {
  #   nativeBuildInputs = (oldAttrs.nativeBuildInputs or []) ++ [addOpenGLRunpath];
  #   postFixup = ''
  #     addOpenGLRunpath $out/bin/btop
  #   '';
  # });

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    zathura
    wget
    firefox
    alacritty
    git 
    stack
    jdk
    unzip
    rofi
    btop
    htop
    picom
    cmake
    clang
    clang-tools
    llvm
    gcc
    steam-run	
    ninja
    gnumake
    python3
    glew
    glfw3
    telegram-desktop
    mpv
    cudatoolkit
    linuxPackages.nvidia_x11
    libGLU libGL
    xorg.libXi xorg.libXmu freeglut
    xorg.libXext xorg.libX11 xorg.libXv xorg.libXrandr zlib
    nitrogen
    nvitop
    transmission-gtk
    sxiv
    lutris
    wine
    emacs
    # cutter
    nushell
    inkscape
    zsh
    fluent-gtk-theme
    texlive.combined.scheme-full
    zathura
    glm
    imagemagick
    zoom-us
    obs-studio
    flameshot
    vial
    maim
    xclip
    unrar
    killall
    brave
    pavucontrol
    ncdu
    manix
    home-manager
    kitty
    st
    xournalpp
    libtool
    neofetch
    fastfetch
    pv
    brave
    # feh
    tty-clock
    krita
    gimp
    screenkey
    cached-nix-shell
    pulseaudio
    comma
  ];

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


  hardware.bluetooth.enable = true; # enables support for Bluetooth
  hardware.bluetooth.powerOnBoot = true; # powers up the default Bluetooth controller on boot

  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk
    noto-fonts-emoji
    jetbrains-mono
    fira-code
    fira-code-symbols
    fira
    iosevka-comfy.comfy
    iosevka-comfy.comfy-duo
    iosevka-comfy.comfy-fixed
    iosevka-comfy.comfy-motion
    iosevka-comfy.comfy-motion-duo
    iosevka-comfy.comfy-motion-fixed
    iosevka-comfy.comfy-wide
    iosevka-comfy.comfy-wide-duo
    iosevka-comfy.comfy-wide-fixed
    iosevka-comfy.comfy-wide-motion
    iosevka-comfy.comfy-wide-motion-duo
    iosevka-comfy.comfy-wide-motion-fixed
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

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.

  networking.firewall = {
    enable = false;
    allowedTCPPorts = [ 80 443 ];
  }; 
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.

  # NOTE: Doesn't work with flakes, so I disabled it:
  # system.copySystemConfiguration = true;

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

