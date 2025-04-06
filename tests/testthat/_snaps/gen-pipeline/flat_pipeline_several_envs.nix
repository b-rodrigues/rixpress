let
  default = import ./default.nix;
defaultPkgs = default.pkgs;
defaultShell = default.shell;
defaultBuildInputs = defaultShell.buildInputs;
defaultConfigurePhase = ''
    cp ${./_rixpress/} 
    mkdir -p $out
  '';
  
default2 = import ./tempdir/default2.nix;
default2Pkgs = default2.pkgs;
default2Shell = default2.shell;
default2BuildInputs = default2Shell.buildInputs;
default2ConfigurePhase = ''
    cp ${./_rixpress/} 
    mkdir -p $out
  '';
  
  
  # Function to create R derivations
  makeRDerivation = { name, buildInputs, configurePhase, buildPhase, src ? null }:
    defaultPkgs.stdenv.mkDerivation {
      inherit name src;
      dontUnpack = true;
      inherit buildInputs configurePhase buildPhase;
      installPhase = ''
        # This install phase will copy either an rds, or a
        # pickle to $out/. This is needed because reticulate::py_save_object
        # runs as an R derivation, but outputs a python output.
        cp ${name}.rds $out/ 2>/dev/null || cp ${name}.pickle $out/
      '';
    };

  # Define all derivations
    mtcars_am = makeRDerivation {
    name = "mtcars_am";
    buildInputs = defaultBuildInputs;
    configurePhase = defaultConfigurePhase;
    buildPhase = ''
      Rscript -e "
        source('libraries.R')
        mtcars_am <- dplyr::filter(mtcars, am == 1)
        saveRDS(mtcars_am, 'mtcars_am.rds')"
    '';
  };

  mtcars_head = makeRDerivation {
    name = "mtcars_head";
    buildInputs = tempdir_default2BuildInputs;
    configurePhase = tempdir_default2ConfigurePhase;
    buildPhase = ''
      Rscript -e "
        source('libraries.R')
        mtcars_head <- head(mtcars_am)
        saveRDS(mtcars_head, 'mtcars_head.rds')"
    '';
  };

  # Generic default target that builds all derivations
  allDerivations = defaultPkgs.symlinkJoin {
    name = "all-derivations";
    paths = with builtins; attrValues { inherit mtcars_am mtcars_head; };
  };

in
{
  inherit mtcars_am mtcars_head;
  default = allDerivations;
}
