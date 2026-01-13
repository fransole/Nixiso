{ pkgs, ... }: {
  # Create live user
  users.users.nixos = {
    isNormalUser = true;
    description = "Live User";
    extraGroups = [ "wheel" "networkmanager" "docker" "video" ];
    shell = pkgs.zsh;
    initialPassword = "";
  };

  # Passwordless sudo for wheel group
  security.sudo.wheelNeedsPassword = false;

  # Auto-login for live user
  services.displayManager.autoLogin = {
    enable = true;
    user = "nixos";
  };

  # Workaround for auto-login (disable getty)
  systemd.services."getty@tty1".enable = false;
  systemd.services."autovt@tty1".enable = false;

  # ZSH configuration
  programs.zsh = {
    enable = true;
    enableCompletion = true;

    # Load Powerlevel10k theme
    promptInit = ''
      source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme
    '';

    # Source p10k config if available
    interactiveShellInit = ''
      # Source p10k config
      [[ -f /etc/nixos/assets/p10k.zsh ]] && source /etc/nixos/assets/p10k.zsh
    '';

    # Useful aliases from your config
    shellAliases = {
      ls = "lsd";
      cat = "bat --paging=never";
      grep = "rg";
      rm = "gtrash put";
      l = "lsd -la";
      ll = "lsd -l";
      lt = "lsd --tree";
    };
  };

  # Copy p10k config to system location
  environment.etc."nixos/assets/p10k.zsh".source = ../assets/p10k.zsh;
}
