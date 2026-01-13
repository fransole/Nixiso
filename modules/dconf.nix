{ pkgs, lib, ... }: {
  # Enable dconf for GNOME settings
  programs.dconf.enable = true;

  # Create dconf profile for system-wide defaults
  environment.etc."dconf/profile/user".text = ''
    user-db:user
    system-db:local
  '';

  # Create dconf database with system defaults
  environment.etc."dconf/db/local.d/00-dark-mode".text = ''
    [org/gnome/desktop/interface]
    color-scheme='prefer-dark'
    gtk-theme='Adwaita-dark'
    font-antialiasing='grayscale'
    font-hinting='slight'
    clock-show-weekday=true
    clock-format='24h'

    [org/gnome/desktop/wm/preferences]
    button-layout='appmenu:minimize,close'

    [org/gnome/desktop/peripherals/touchpad]
    natural-scroll=false
    two-finger-scrolling-enabled=true

    [org/gnome/shell]
    disable-extension-version-validation=true
    favorite-apps=['firefox.desktop', 'code.desktop', 'org.gnome.Console.desktop', 'org.gnome.Nautilus.desktop']

    [org/gnome/desktop/wm/keybindings]
    close=['<Alt>q']

    [org/gnome/shell/keybindings]
    show-screenshot-ui=['<Shift><Super>s']
  '';

  # Update dconf database (required after creating database files)
  system.activationScripts.dconfUpdate = lib.stringAfter [ "etc" ] ''
    if [ -x ${pkgs.dconf}/bin/dconf ]; then
      ${pkgs.dconf}/bin/dconf update
    fi
  '';
}
