let isDeskop = import ~/.device.nix == "desktop";
in [
  # common packages

  (self: super: {
    # get libgbm for shapez.io
    steam = super.steam.override { extraPkgs = pkgs: [ pkgs.mesa ]; };
  })
] ++ (if isDeskop then [
  (self: super: { liquidctl = super.callPackage /home/aamaruvi/pkgs/liquidctl.nix {}; })
  ] else [
  (self: super: { gruvbox-gtk = super.callPackage /home/aamaruvi/pkgs/gruvbox-gtk.nix {}; })
])
