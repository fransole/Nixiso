{ config, pkgs, lib, ... }: {
  imports = [
    ./modules/gnome.nix
    ./modules/stylix.nix
    ./modules/dconf.nix
    ./modules/packages.nix
    ./modules/users.nix
  ];

  # ISO image settings
  isoImage = {
    makeEfiBootable = true;
    makeUsbBootable = true;
    makeBiosBootable = true;
    squashfsCompression = "zstd -Xcompression-level 6"; # Faster builds
    volumeID = "NIXOS-LIVE";
    edition = "dev-environment";
  };

  # Networking
  networking = {
    hostName = "nixos-live";
    networkmanager.enable = true;
    wireless.enable = lib.mkForce false;
  };

  # Nix settings
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    substituters = [
      "https://cache.nixos.org"
      "https://nix-community.cachix.org"
      "https://cache.numtide.com"
    ];
    trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
    ];
  };

  # Docker (rootless)
  virtualisation.docker = {
    enable = true;
    rootless = {
      enable = true;
      setSocketVariable = true;
    };
  };

  # ZSH
  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;

  # Latest kernel for better hardware support
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Filesystem support
  boot.supportedFilesystems = lib.mkForce [
    "btrfs" "vfat" "f2fs" "xfs" "ntfs" "ext4"
  ];

  # Timezone
  time.timeZone = "America/Chicago";

  # Locale
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  system.stateVersion = "25.05";
}
