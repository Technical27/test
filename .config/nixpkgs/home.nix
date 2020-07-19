{ config, pkgs, lib, ... }:

let
  device = import ~/.device.nix;
  isLaptop = device == "laptop";
  isDesktop = device == "desktop";
in {
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    ripgrep
    nerdfonts
    yadm
    niv
    gsettings-desktop-schemas
    xdg_utils

    ranger

    discord
    minecraft
    killall
    nix-index
    neofetch
    steam
    jump
  ] ++ lib.optionals isLaptop [
    #sway stuff
    swaylock
    swayidle
    waybar
    udiskie
    wofi
    brightnessctl
    libappindicator-gtk3
    wl-clipboard

    zoom-us
  ] ++ lib.optionals isDesktop [
    gnomeExtensions.caffeine
    gnome3.gnome-tweaks
    pop-shell
    lutris
    razergenie
    virt-manager
    openrgb
  ];

  xdg.mimeApps.enable = true;
  xdg.mimeApps.defaultApplications =
    let
      browser = [ "firefox.desktop" ];
      files = [ "ranger.desktop" ];
    in {
      "text/html" = browser;

      "x-scheme-handler/http"    = browser;
      "x-scheme-handler/https"   = browser;
      "x-scheme-handler/about"   = browser;
      "x-scheme-handler/unknown" = browser;
      "inode/directory" = files;
    };

  programs.neovim = {
    enable = true;
    plugins = with pkgs.vimPlugins; [
      coc-nvim
      vim-airline
      vim-devicons
      fzf-vim
      vim-polyglot
      gruvbox
      undotree
      vim-fugitive
      vim-snippets
      vim-lastplace
      auto-pairs
      coc-fzf
      sensible
      commentary
      vim-lion
    ];
    withNodeJs = true;
    withPython3 = true;
    extraConfig = import ./nvim.nix;
  };

  programs.direnv.enable    = true;
  programs.fzf.enable       = true;
  programs.bat.enable       = true;
  programs.htop.enable      = true;
  programs.firefox.enable   = true;
  programs.firefox.package  = if isLaptop then pkgs.firefox-wayland else pkgs.firefox;

  programs.mako = lib.mkIf isLaptop {
    enable = true;
    textColor = "#ebdbb2";
    backgroundColor = "#282828";
    borderSize = 0;
    defaultTimeout = 2000;
  };


  xsession.preferStatusNotifierItems = true;
  services.lorri.enable = true;
  services.redshift = lib.mkIf isLaptop {
    enable = true;
    latitude = "33.748";
    longitude = "-84.387";
    package = pkgs.redshift-wlr;
  };

  programs.starship = {
    enable = true;
    settings = {
      # annoying
      nix_shell = { disabled = true; };
      # very slow
      haskell   = { disabled = true; };
    };
  };

  programs.kitty = with import ./kitty.nix; {
    enable = true;
    inherit keybindings extraConfig;
  };

  programs.git = {
    enable    = true;
    userName  = "Aamaruvi Yogamani";
    userEmail = "38222826+Technical27@users.noreply.github.com";

    signing = {
      signByDefault = true;
      key = "F930CFBFF5D7FDC3";
    };

    extraConfig = {
      pull = { rebase = false; };
      credential = {
        helper = "/home/aamaruvi/.nix-profile/bin/git-credential-libsecret";
      };
    };

    package = pkgs.gitFull;
  };
  programs.fish = {
    enable = true;
    shellInit = ''
      set FZF_DEFAULT_OPTS '--color bg+:-1'
      set EDITOR 'nvim'

      set -g fish_color_autosuggestion '555'  'brblack'
      set -g fish_color_cancel -r
      set -g fish_color_command --bold
      set -g fish_color_comment 'brblack'
      set -g fish_color_cwd green
      set -g fish_color_cwd_root red
      set -g fish_color_end brmagenta
      set -g fish_color_error brred
      set -g fish_color_escape 'bryellow'  '--bold'
      set -g fish_color_history_current --bold
      set -g fish_color_host normal
      set -g fish_color_match --background=brblue
      set -g fish_color_normal normal
      set -g fish_color_operator bryellow
      set -g fish_color_param cyan
      set -g fish_color_quote yellow
      set -g fish_color_redirection brblue
      set -g fish_color_search_match 'bryellow'  '--background=brblack'
      set -g fish_color_selection 'white' '--bold'  '--background=brblack'
      set -g fish_color_user brgreen
      set -g fish_color_valid_path --underline

      fish_vi_key_bindings
    '';
    interactiveShellInit = "source (jump shell fish | psub)";
    shellAliases = {
      make = "make -j8";
      hme = "$EDITOR ~/.config/nixpkgs/home.nix";
    };
  };

  wayland.windowManager.sway = lib.mkIf isLaptop {
    enable = true;
    extraConfig = ''
      seat seat0 xcursor_theme default 48
      default_border none
    '';
    wrapperFeatures.gtk = true;
    xwayland = true;
    systemdIntegration = false;
    extraSessionCommands = ''
      # wayland stuff
      export SDL_VIDEODRIVER=wayland
      export QT_QPA_PLATFORM=wayland-egl
      export QT_WAYLAND_FORCE_DPI=physical
      export QT_WAYLAND_DISABLE_WINDOWDECORATION=1

      # get apps to display tray icons
      export XDG_CURRENT_DESKTOP=Unity
    '';

    config = {
      output = {
        "eDP-1" = {
          scale = "2";
          bg = "~/Pictures/wallpaper.jpg fill";
        };
      };
      input = {
        "1739:30383:DELL07E6:00_06CB:76AF_Touchpad" = {
          tap = "enabled";
          natural_scroll = "enabled";
          pointer_accel = "0.3";
          dwt = "enabled";
        };
      };
      bars = [{ command = "${pkgs.waybar}/bin/waybar"; }];
      gaps.inner = 10;
      terminal = "kitty";
      modifier = "Mod4";
      menu = "wofi --show drun";
      startup = [
        {
          command = ''
            exec swayidle -w \
              timeout 300 'swaylock -f -c 000000' \
              timeout 600 'swaymsg "output * dpms off"' \
                resume 'swaymsg "output * dpms on"' \
              before-sleep 'swaylock -f -c 000000'
          '';
        }
        {
          command = "udiskie -a -n --appindicator";
        }
      ];
      keybindings = let
        amixer = "exec amixer -q set Master";
        brctl = "exec brightnessctl set";
      in lib.mkOptionDefault {
        "XF86AudioRaiseVolume"  = "${amixer} 10%+ unmute";
        "XF86AudioLowerVolume"  = "${amixer} 10%- unmute";
        "XF86AudioMute"         = "${amixer} toggle";

        "XF86MonBrightnessUp"   = "${brctl} 10%+";
        "XF86MonBrightnessDown" = "${brctl} 10%-";
      };
    };
  };
  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage when a
  # new Home Manager release introduces backwards incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "20.03";
}
