let isDeskop = import ~/.device.nix == "desktop";
in [
  (self: super: { glfw-wayland = super.callPackage /home/aamaruvi/pkgs/glfw.nix {}; })
  (self: super: {
    discord = super.discord.overrideAttrs(old: rec {
      version = "0.0.12";
      src = super.fetchurl {
        url = "https://dl.discordapp.net/apps/linux/${version}/discord-${version}.tar.gz";
        sha256 = "0qrzvc8cp8azb1b2wb5i4jh9smjfw5rxiw08bfqm8p3v74ycvwk8";
      };
    });
  })
] ++ (if isDeskop then [
  (self: super: { liquidctl = super.callPackage /home/aamaruvi/pkgs/liquidctl.nix {}; })
] else [])
