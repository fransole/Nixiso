{ lib, ... }: {
  programs.dconf.enable = true;

  # System-wide dconf defaults (applied to all users)
  programs.dconf.profiles.user.databases = [{
    settings = {
      # Interface - Dark Mode
      "org/gnome/desktop/interface" = {
        color-scheme = "prefer-dark";
        font-antialiasing = "grayscale";
        font-hinting = "slight";
        clock-show-weekday = true;
        clock-format = "24h";
      };

      # Mutter (Window Manager) Settings
      "org/gnome/mutter" = {
        experimental-features = [
          "scale-monitor-framebuffer"  # Fractional scaling
          "variable-refresh-rate"      # VRR support
        ];
        edge-tiling = true;
      };

      # Touchpad Settings
      "org/gnome/desktop/peripherals/touchpad" = {
        natural-scroll = false;
        two-finger-scrolling-enabled = true;
      };

      # Shell Settings
      "org/gnome/shell" = {
        disable-extension-version-validation = true;
        favorite-apps = [
          "firefox.desktop"
          "code.desktop"
          "org.gnome.Console.desktop"
          "org.gnome.Nautilus.desktop"
        ];
      };

      # Keybindings
      "org/gnome/desktop/wm/keybindings" = {
        close = ["<Alt>q"];
      };

      "org/gnome/shell/keybindings" = {
        show-screenshot-ui = ["<Shift><Super>s"];
      };

      # Privacy Settings
      "org/gnome/desktop/privacy" = {
        remove-old-temp-files = true;
        remove-old-trash-files = true;
      };

      # Night Light
      "org/gnome/settings-daemon/plugins/color" = {
        night-light-enabled = true;
        night-light-schedule-from = 22.0;
      };

      # Window Manager Preferences
      "org/gnome/desktop/wm/preferences" = {
        button-layout = "appmenu:minimize,close";
      };
    };
  }];
}
