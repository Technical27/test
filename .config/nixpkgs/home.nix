{ config, pkgs, ... }:

{
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    ripgrep
    nerdfonts
    yadm
    niv
    wl-clipboard
    gsettings-desktop-schemas

    ranger

    discord
    minecraft
    killall
    nix-index
    neofetch
    steam
    zoom-us
  ];

  xdg.mimeApps.enable = true;
  xdg.mimeApps.defaultApplications =
    let
      browser = [ "firefox.desktop" ];
    in {
      "text/html" = browser;

      "x-scheme-handler/http"    = browser;
      "x-scheme-handler/https"   = browser;
      "x-scheme-handler/about"   = browser;
      "x-scheme-handler/unknown" = browser;
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

  services.lorri.enable    = true;
  programs.direnv.enable   = true;
  programs.fzf.enable      = true;
  programs.bat.enable      = true;
  programs.htop.enable     = true;
  programs.firefox.enable  = true;
  programs.firefox.package = pkgs.firefox-wayland;

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
      set SHELL 'bash'
      set EDITOR 'nvim'
    '';
    shellAliases = {
      make = "make -j8";
    };
  };

  wayland.windowManager.sway = {
    enable = true;
    extraConfig = let
      amixer = "exec amixer -q set Master";
      brctl = "exec brightnessctl set";
    in ''
      seat seat0 xcursor_theme default 48

      bindsym XF86AudioRaiseVolume ${amixer} 10%+ unmute
      bindsym XF86AudioLowerVolume ${amixer} 10%- unmute
      bindsym XF86AudioMute ${amixer} toggle

      bindsym XF86MonBrightnessUp ${brctl} 10%+
      bindsym XF86MonBrightnessDown ${brctl} 10%-

      default_border none
    '';
    wrapperFeatures.gtk = true;
    xwayland = true;
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
      ];
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
