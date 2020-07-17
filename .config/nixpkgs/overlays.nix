[
  (self: super: {
    openrgb = with import <nixpkgs> {}; super.callPackage /home/aamaruvi/pkgs/openrgb.nix {};
  })
  (self: super: {
    pop-shell = with import <nixpkgs> {}; super.callPackage /home/aamaruvi/pkgs/pop.nix {};
  })
]
