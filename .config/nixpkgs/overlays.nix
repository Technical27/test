let isDeskop = import ~/.device.nix == "desktop";
in [
  # common packages

  (self: super: {
    # get libgbm for shapez.io
    steam = super.steam.override { extraPkgs = pkgs: [ pkgs.mesa ]; };
    discord = super.discord.override (rec {
      version = "0.0.13";
      src = super.fetchurl {
        url = "https://dl.discordapp.net/apps/linux/${version}/discord-${version}.tar.gz";
        sha256 = "0d5z6cbj9dg3hjw84pyg75f8dwdvi2mqxb9ic8dfqzk064ssiv7y";
      };
    });
  })
] ++ (if isDeskop then [
  (self: super: { liquidctl = super.callPackage /home/aamaruvi/pkgs/liquidctl.nix {}; })
  ] else [
    (self: super: {
      gruvbox-gtk = super.callPackage /home/aamaruvi/pkgs/gruvbox-gtk.nix {};
      gruvbox-icons = super.callPackage /home/aamaruvi/pkgs/gruvbox-icons.nix {};
    })
])
