{ config, pkgs, lib, ... }:

let
  device = import ~/.device.nix;
  isLaptop = device == "laptop";
  isDesktop = device == "desktop";
in {
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  home.username = "aamaruvi";
  home.homeDirectory = toString ~/.;

  home.sessionVariables = rec {
    MOZ_ENABLE_WAYLAND                  = "1";
    MOZ_USE_XINPUT2                     = "1";
    XDG_SESSION_TYPE                    = "wayland";
    XDG_CURRENT_DESKTOP                 = "sway";
    XCURSOR_PATH                        = toString ~/.local/share/icons;
    SDL_VIDEODRIVER                     = "wayland";
    QT_QPA_PLATFORM                     = "wayland-egl";
    QT_WAYLAND_FORCE_DPI                = "physical";
    QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
  };

  home.packages = with pkgs; [
    ripgrep
    nerdfonts
    yadm
    niv
    glib
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
    libreoffice
    gimp
  ] ++ lib.optionals isLaptop [
    #sway stuff
    sway-contrib.grimshot
    wofi
    brightnessctl
    libappindicator-gtk3
    wl-clipboard
    zoom-us
    teams
  ] ++ lib.optionals isDesktop [
    lutris
    razergenie
    virt-manager
    openrgb
    liquidctl
    obs-studio
    olive-editor
  ];

  xdg.mimeApps.enable = true;
  xdg.mimeApps.defaultApplications =
    let
      browser = [ "firefox.desktop" ];
      files = [ "ranger.desktop" ];
    in {
      "text/html"                = browser;

      "x-scheme-handler/http"    = browser;
      "x-scheme-handler/https"   = browser;
      "x-scheme-handler/msteams" = "teams.desktop";
      "inode/directory"          = files;
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
      vim-sensible
      coc-fzf
      lexima-vim
      vim-move
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


  programs.zathura = {
    enable = true;
    options = {
      font = "'JetBrains Mono NerdFont' 13";
      default-bg = "#282828";
      defualt-fg = "#ebdbb2";
      statusbar-bg = "#282828";
      statusbar-fg = "#ebdbb2";
      statusbar-home-tilde = true;
    };
  };
  programs.mako = lib.mkIf isLaptop {
    enable = true;
    textColor = "#ebdbb2";
    backgroundColor = "#282828";
    borderSize = 0;
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
      pull = { rebase = true; };
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
      set XDG_DATA_DIRS "${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/${pkgs.gsettings-desktop-schemas.name}:$XDG_DATA_DIRS"

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
      hm = "home-manager";
      hme = "$EDITOR ~/.config/nixpkgs/home.nix";
    };
  };

  wayland.windowManager.sway = lib.mkIf isLaptop {
    package = lib.mkForce null;
    enable = true;
    extraConfig = ''
      seat seat0 xcursor_theme WhiteSur-cursors 48
      default_border none
    '';
    wrapperFeatures.gtk = true;
    systemdIntegration = false;

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
      gaps.inner = 10;
      terminal = "kitty";
      modifier = "Mod4";
      menu = "wofi --show drun";
      bars = [{ command = "${pkgs.waybar}/bin/waybar"; }];
      startup = let
        gnome-schema = "gsettings set org.gnome.desktop.interface";
        swayidle = "${pkgs.swayidle}/bin/swayidle";
        swaylock = "${pkgs.swaylock}/bin/swaylock";
      in [
        {
          command = ''
            ${swayidle} -w \
              timeout 300 '${swaylock} -f -c 000000' \
              timeout 600 'swaymsg "output * dpms off"' \
                resume 'swaymsg "output * dpms on"' \
              before-sleep '${swaylock} -f -c 000000'
          '';
        }
        {
          command = "${pkgs.udiskie}/bin/udiskie -a -n --appindicator";
        }
        {
          command = "${gnome-schema} cursor-theme 'WhiteSur-cursors'";
        }
        {
          command = "${gnome-schema} cursor-size 48";
        }
        {
          command = "${pkgs.pipewire}/bin/pipewire";
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
  home.stateVersion = "20.09";
}
