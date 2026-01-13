{ pkgs, lib, ... }:
let
  scheme = "${pkgs.base16-schemes}/share/themes/kanagawa.yaml";
in {
  stylix = {
    enable = true;
    autoEnable = true;

    # Dark mode - KEY SETTING
    polarity = "dark";

    # Kanagawa color scheme
    base16Scheme = scheme;

    # System-level targets (no home-manager)
    targets.gnome.enable = true;
    targets.gtk.enable = true;
    targets.plymouth.enable = false;

    # Solid color background using base02
    image = pkgs.runCommand "solid-color-background.png" {} ''
      COLOR=$(${lib.getExe pkgs.yq} -r .palette.base02 ${scheme})
      ${lib.getExe pkgs.imagemagick} -size 1x1 xc:$COLOR $out
    '';

    # Cursor
    cursor = {
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Ice";
      size = 24;
    };

    # Fonts
    fonts = {
      serif = {
        package = pkgs.noto-fonts;
        name = "Noto Serif";
      };
      sansSerif = {
        package = pkgs.noto-fonts;
        name = "Noto Sans";
      };
      monospace = {
        package = pkgs.nerd-fonts.noto;
        name = "NotoMono Nerd Font";
      };
      emoji = {
        package = pkgs.noto-fonts-color-emoji;
        name = "Noto Color Emoji";
      };
      sizes = {
        applications = 12;
        desktop = 11;
        terminal = 11;
        popups = 10;
      };
    };

    # Opacity
    opacity = {
      applications = 0.95;
      desktop = 0.95;
      popups = 0.95;
      terminal = 0.90;
    };
  };
}
