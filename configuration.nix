### Currently works for my lenovo laptop (on UEFI).
### Only need to change boot.loader for it to compile a BIOS loader :)

# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

let
  home-manager = builtins.fetchGit {
    url = "https://github.com/rycee/home-manager.git";
    rev = "dd94a849df69fe62fe2cb23a74c2b9330f1189ed"; # CHANGEME 
    ref = "release-18.09";
  }; 
  tilde = "/home/jin/nixos-config/tilde"; ### should be changed manually while running the first time after fresh installing nixos
in {
  imports =
    [ # Include the results of the hardware scan.
      /etc/nixos/hardware-configuration.nix
      (import "${home-manager}/nixos")
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.kernelPackages = pkgs.linuxPackages;
  #boot.kernelPackages = pkgs.linuxPackages_4_4;

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  networking.interfaces.enp8s0.useDHCP = true;
  networking.interfaces.wlp9s0.useDHCP = true;
  networking.hostName = "guu-nixos"; # Define your hostname.
  networking.networkmanager.enable = true;
  programs.nm-applet.enable = true; # use nmtui to easily config wifi ;)


  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  # i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  # };

  # Set your time zone.
  time.timeZone = "America/Chicago";

  users.defaultUserShell = pkgs.zsh;
  #programs.zsh = {
  #  enable = true;
  #  enableCompletion = true;
  #  autosuggestions.enable = true;
  #  syntaxHighlighting.enable = true;
  #  interactiveShellInit=''
  #    [ -z "$HISTFILE" ] && HISTFILE="$HOME/.config/zsh/.zsh_hist"
  #    HISTFILESIZE=50000
  #    HISTSIZE=50000
  #    SAVEHIST=50000
  #  '';
  #};

  # List packages installed in system profile. To search, run:
  environment.systemPackages = with pkgs; [
    wpa_supplicant_gui gcc binutils nix feh i3lock
    wget vim neovim sudo manpages gitAndTools.gitFull
    trayer dmenu scrot atool
    haskellPackages.xmobar
    qutebrowser alacritty htop ranger unzip poppler

    irssi xcape zathura ghostscript 
    emacs mupdf tree fzf less ledger 
    maim ripgrep rsync imagemagick
    gnupg youtube-dl sxiv xclip xsel hack-font curl ffmpeg tree

    ueberzug # image previewer in ranger

    #unrar ## -- taken away as it's not free
    unzip xz zip firefox
    vlc mpv 
  ];

  # Despite looking like normal packages, simply adding these font packages to
  # your environment.systemPackages won't make the fonts accessible to
  # applications. To achieve that, put these packages in the fonts.fonts NixOS
  # options list instead.
  # - source :: https://nixos.wiki/wiki/Fonts
  fonts = {
    enableDefaultFonts = true;
    fonts = with pkgs; [
      terminus_font ## This is the font I like, use `fc-list | grep Terminus` to see its name <3
      unifont
      wqy_microhei wqy_zenhei
      hack-font noto-fonts noto-fonts-cjk noto-fonts-emoji 
      liberation_ttf fira-code fira-code-symbols mplus-outline-fonts
      dina-font proggyfonts source-code-pro inconsolata
      # unfree: symbola
    ];

    fontconfig.penultimate.enable = false;
    fontconfig.defaultFonts = {
      # IMO WQY Zen Hei plays slightly better with Terminus
      serif     = ["Terminus" "WenQuanYi Zen Hei" "Unifont" "WenQuanYi Micro Hei"];
      sansSerif = ["Terminus" "WenQuanYi Zen Hei" "Unifont" "WenQuanYi Micro Hei"];
      monospace = ["Terminus" "WenQuanYi Zen Hei" "Unifont" "WenQuanYi Micro Hei"];
    };
  };

  environment.variables = {
    EDITOR = "vim";
    BROWSER = "qutebrowser";
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  #   pinentryFlavor = "gnome3";
  # };

# Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound: config volume interactively using alsamixer.
  sound.enable = true;
  hardware.pulseaudio.enable = true; 

  # Enable touchpad support.
  services.xserver.libinput.enable = true;
  services.xserver.libinput.middleEmulation = true;
  services.xserver.libinput.tapping = true;


  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.jin = {
    isNormalUser = true;
    extraGroups = [ "wheel" "audio" "networkmanager" ]; # Enable ‘sudo’ for the user.
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "20.03"; # Did you read the comment?

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;
  services.sshd.enable = true; # what's the difference??

  services.xserver = {
    enable = true;
    windowManager.xmonad = {
      enable = true;
      enableContribAndExtras = true;
      extraPackages = haskellPackages: [
        haskellPackages.xmonad-contrib
        haskellPackages.xmonad-extras
        haskellPackages.xmonad
      ];
    };
    desktopManager.xterm.enable = false;
    displayManager.startx.enable = true;
    # capslock => control 
    xkbOptions = "ctrl:nocaps"; # now capslock means control :)
  };

  home-manager.users.jin = { 
    programs.home-manager.enable = true;

    home.file = {
      "./.wall.png".source = "${tilde}/.wall.png";
      "./.scripts".source = "${tilde}/.scripts";
      #"./.config".source = "${tilde}/.config"; # .config usually got modified. eg ranger wouldn't work this way
      ".xinitrc".text = builtins.readFile "${tilde}/.xinitrc";
      #".config/alacritty.yml".text = builtins.readFile "${tilde}/alacritty.yml";

      #".config/qutebrowser/config.py".text =
        #builtins.readFile "${tilde}/.config/qutebrowser/config.py";
      #".config/qutebrowser/void.html".text =
        #builtins.readFile "${tilde}/.config/qutebrowser/void.html";
      #".config/qutebrowser/quickmarks".text =
        #builtins.readFile "${tilde}/.config/qutebrowser/quickmarks";

      # below we configure ranger..
      #".config/ranger/commands.py".text =
        #builtins.readFile "${tilde}/.config/ranger/commands.py";
      #".config/ranger/rc.conf".text =
        #builtins.readFile "${tilde}/.config/ranger/rc.conf";
      #".config/ranger/scope.sh" = {
          #text = builtins.readFile "${tilde}/.config/ranger/scope.sh";
          #executable = true;
      #};
      #".config/ranger/shortcuts_jin.conf".text =
        #builtins.readFile "${tilde}/.config/ranger/shortcuts_jin.conf";
      #".config/ranger/luke_ranger_readme.md".text =
        #builtins.readFile "${tilde}/.config/ranger/luke_ranger_readme.md";
      #".config/ranger/rifle.conf".text =
        #builtins.readFile "${tilde}/.config/ranger/rifle.conf";
      #".config/ranger/shortcuts.conf".text =
        #builtins.readFile "${tilde}/.config/ranger/shortcuts.conf";
    };

    #programs.git = {
    #  enable = true; 
    #  userName = "jcguu95";
    #  userEmail = "jcguu95@gmail.com"; 
    #};

    programs.vim = { 
      enable = true;
      settings = {
        relativenumber = true;
	number = true;
      };
      plugins = [
        "idris-vim"
	"sensible"
	"vim-airline"
	"The_NERD_tree" # file system explorer
	"fugitive" "vim-gitgutter" #git
      ];
    };

    #programs.zsh = {
    #  enable = true;
    #  enableAutosuggestions = true;
    #  enableCompletion = true;
    #  dotDir = ".config/zsh";
    #  history.extended = true;
    #  history.path = ".config/zsh/.zsh_history";
    #};
  };

console.font = "Lat2-Terminus16";

# Default Color (I love it but don't know its color codes.)
console.colors = []; # TODO: Find out its color codes!

# Dark Gruvbox
#console.colors = [ "282828" "cc241d" "98971a" "d79921"
#                   "458588" "b16286" "689d6a" "a89984"
#                   "928374" "fb4934" "b8bb26" "fabd2f"
#                   "83a598" "d3869b" "83c07c" "ebdbb2" ];
}
