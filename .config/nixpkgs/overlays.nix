let isDeskop = import ~/.device.nix == "desktop";
in [
  # common packages
] ++ (if isDeskop then [
  (self: super: { liquidctl = super.callPackage /home/aamaruvi/pkgs/liquidctl.nix {}; })
] else [
  # laptop packages
])
