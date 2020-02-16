{forShell ? false, ghcVersion ? "ghc865" }:
let
  pkgs = import ./nixpkgs.nix;  
  ghc = pkgs.haskell.packages."${ghcVersion}";
  targets = import ./cabal.nix;
  haskellPackages = ghc.extend (pkgs.lib.composeExtensions
      (self: super: pkgs.haskell.lib.packageSourceOverrides (targets // {
        # any version overrides or submodule package dependencies here
        # some-package = "0.2.0.0";           # fetch specific hackage version
        # some-package = ./dir/subproject;    # git submodule packages
      }) self super)
      (self: super: {
          ghcWithPackages = p: super.ghcWithPackages (
              f: p f ++ (if forShell then [ f.cabal-install ] else [])
          );
          # any fetch/overrides go here
          # some-package = pkgs.haskell.lib.dontCheck (self.callCabal2nix "some-package" (pkgs.fetchFromGitHub { ... }) {});
          # some-package = pkgs.haskell.lib.overrideCabal super.some-package (drv: { patches = (drv.patches or [ ... ]); });
      })
  );
  buildSet = pkgs.lib.foldl (ps: p: ps // { ${p.pname} = p; }) {} packages;
  packages = map (t: haskellPackages.${t} ) (builtins.attrNames targets);

  all-hies = import (fetchTarball "https://github.com/infinisil/all-hies/tarball/master") {};
  hie = all-hies.versions."${ghcVersion}";

  tools = [ pkgs.pkgconfig hie ];
in
  if forShell
  then haskellPackages.shellFor { packages = _: packages; buildInputs = tools; }
  else haskellPackages.tta # buildSet # use buildSet to build everything
