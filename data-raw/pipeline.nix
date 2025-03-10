let
  default = import ./default.nix;
  pkgs = default.pkgs;
  shell = default.shell;

  commonBuildInputs = shell.buildInputs;
  commonConfigurePhase = ''
    cp ${./libraries.R} libraries.R
    mkdir -p $out
  '';

  # Function to create R derivations
  makeRDerivation = { name, buildPhase }:
    let rdsFile = "${name}.rds";
    in pkgs.stdenv.mkDerivation {
      inherit name;
      buildInputs = commonBuildInputs;
      dontUnpack = true;
      configurePhase = commonConfigurePhase;
      inherit buildPhase;
      installPhase = ''
        cp ${rdsFile} $out/
      '';
    };

  # Define all derivations
  mtcars_am = makeRDerivation {
    name = "mtcars_am";
    buildPhase = ''
      Rscript -e "
        source('libraries.R')
        mtcars_am <- filter(mtcars, am == 1)
        saveRDS(mtcars_am, 'mtcars_am.rds')"
    '';
  };

  mtcars_head = makeRDerivation {
    name = "mtcars_head";
    buildPhase = ''
      Rscript -e "
        source('libraries.R')
        mtcars_am <- readRDS('${mtcars_am}/mtcars_am.rds')
        mtcars_head <- head(mtcars_am)
        saveRDS(mtcars_head, 'mtcars_head.rds')"
    '';
  };

  mtcars_tail = makeRDerivation {
    name = "mtcars_tail";
    buildPhase = ''
      Rscript -e "
        source('libraries.R')
        mtcars_head <- readRDS('${mtcars_head}/mtcars_head.rds')
        mtcars_tail <- tail(mtcars_head)
        saveRDS(mtcars_tail, 'mtcars_tail.rds')"
    '';
  };

  page = pkgs.stdenv.mkDerivation {
    name = "page";
    src = ./.;
    buildInputs = [ commonBuildInputs pkgs.which pkgs.quarto ];
    buildPhase = ''
  mkdir home
  export HOME=$PWD/home
  substituteInPlace page.qmd --replace-fail 'drv_read("mtcars_head")' 'drv_read("${mtcars_head}/mtcars_head.rds")'
  substituteInPlace page.qmd --replace-fail 'drv_read("mtcars_tail")' 'drv_read("${mtcars_tail}/mtcars_tail.rds")'
  quarto render page.qmd --output-dir $out
    '';
  };

  # Generic default target that builds all derivations
  allDerivations = pkgs.symlinkJoin {
    name = "all-derivations";
    paths = with builtins; attrValues { inherit mtcars_am mtcars_head mtcars_tail page; };
  };

in
{
  inherit mtcars_am mtcars_head mtcars_tail page;  # Make individual derivations available as attributes
  default = allDerivations;  # Set the default target to build everything
}
