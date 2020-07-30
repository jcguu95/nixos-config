# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  # Define on which hard drive you want to install Grub.
  boot.loader.grub.device = "/dev/sda"; # or "nodev" for efi only

  networking.hostName = "guu-nixos"; # Define your hostname.
  #networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  networking.interfaces.enp0s3.useDHCP = true;

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
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    syntaxHighlighting.enable = true;
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    gcc binutils nix
    wget vim neovim sudo manpages gitAndTools.gitFull
    trayer dmenu picom nitrogen
    haskellPackages.xmobar
    qutebrowser alacritty htop ranger unzip
  ];

  # Despite looking like normal packages, simply adding these font packages to
  # your environment.systemPackages won't make the fonts accessible to
  # applications. To achieve that, put these packages in the fonts.fonts NixOS
  # options list instead.
  # - source :: https://nixos.wiki/wiki/Fonts
  fonts.fonts = with pkgs; [
    terminus_font ## This is the font I like, use `fc-list | grep Terminus` to see its name <3
    hack-font
    noto-fonts
    noto-fonts-cjk
    noto-fonts-emoji
    liberation_ttf
    fira-code
    fira-code-symbols
    mplus-outline-fonts
    dina-font
    proggyfonts
    source-code-pro
  ];

  environment.variables.EDITOR = "nvim";

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  #   pinentryFlavor = "gnome3";
  # };

  # List services that you want to enable:

# Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  # sound.enable = true;
  # hardware.pulseaudio.enable = true;

  # Enable touchpad support.
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.jin = {
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
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
  };

# To use Lenivaya's gorgeous setup, enable the followings:
#
# cf. this issue: https://github.com/Lenivaya/dotfiles/issues/1
# rmk. you might also want to download all configs to ~/.configs for it to work
# properly.
#
#  services.xserver = {
#    windowManager.xmonad = {
#      extraPackages = haskellPackages: [
#        haskellPackages.gloss
#      ];
#      haskellPackages = pkgs.unstable.haskellPackages;
#    };
#
#  nixpkgs.overlays = [
#    (self: super:
#      with super; {
#          unstable = import <unstable> { inherit config; };
#      })
#  ];
#
#################################################################

console.font = "Lat2-Terminus16";

# Default Color (I love it but don't know its color codes.)
console.colors = []; # TODO: Find out its color codes!

# Dark Gruvbox
#console.colors = [ "282828" "cc241d" "98971a" "d79921"
#                   "458588" "b16286" "689d6a" "a89984"
#                   "928374" "fb4934" "b8bb26" "fabd2f"
#                   "83a598" "d3869b" "83c07c" "ebdbb2" ];

# Example colors given in the manpage
#console.colors = [ "002b36" "dc322f" "859900" "b58900"
#                   "268bd2" "d33682" "2aa198" "eee8d5"
#                   "002b36" "cb4b16" "586e75" "657b83"
#                   "839496" "6c71c4" "93a1a1" "fdf6e3" ];

#console.colors = [ "3A3C43" "BE3E48" "869A3A" "C4A535"
#                   "4E76A1" "855B8D" "568EA3" "B8BCB9"
#                   "888987" "FB001E" "0E712E" "C37033"
#                   "176CE3" "FB0067" "2D6F6C" "FCFFB8" ];

}

