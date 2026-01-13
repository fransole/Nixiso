{ pkgs, lib, ... }: {
  # Enable dconf for GNOME settings
  programs.dconf.enable = true;

  # For a live ISO, dconf settings are best handled by the user session
  # Dark mode is enforced via GTK_THEME environment variable in theming.nix
  # Users can customize settings via GNOME Settings or dconf-editor after boot
}
