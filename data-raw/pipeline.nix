let
  default = import ./default.nix;
  defaultPkgs = default.pkgs;
  defaultShell = default.shell;
  defaultBuildInputs = defaultShell.buildInputs;
  defaultConfigurePhase = ''
    cp ${./_rixpress/default_libraries.R} libraries.R
    mkdir -p $out
  '';
default2 = import ./default2.nix;
  default2Pkgs = default2.pkgs;
  default2Shell = default2.shell;
  default2BuildInputs = default2Shell.buildInputs;
  default2ConfigurePhase = ''
    cp ${./_rixpress/default2_libraries.R} libraries.R
    mkdir -p $out
  '';
quarto-env = import ./quarto-env.nix;
  quarto-envPkgs = quarto-env.pkgs;
  quarto-envShell = quarto-env.shell;
  quarto-envBuildInputs = quarto-envShell.buildInputs;
  quarto-envConfigurePhase = ''
    cp ${./_rixpress/quarto-env_libraries.R} libraries.R
    mkdir -p $out
  '';
  
  # Function to create R derivations
  makeRDerivation = { name, buildInputs, configurePhase, buildPhase, src ? null }:
    let rdsFile = "${name}.rds";
    in defaultPkgs.stdenv.mkDerivation {
      inherit name src;
      dontUnpack = true;
      inherit buildInputs configurePhase buildPhase;
      installPhase = ''
        cp ${rdsFile} $out/
      '';
    };

  # Define all derivations
    mtcars = makeRDerivation {
    name = "mtcars";
    src = ./mtcars.csv;
    buildInputs = defaultBuildInputs;
    configurePhase = defaultConfigurePhase;
    buildPhase = ''
      cp $src input_file
Rscript -e "
source('libraries.R')
data <- do.call(function(x) (read.csv(file = x, sep = '|')), list('input_file'))
saveRDS(data, 'mtcars.rds')"
    '';
  };

  mtcars_am = makeRDerivation {
    name = "mtcars_am";
    buildInputs = default2BuildInputs;
    configurePhase = default2ConfigurePhase;
    buildPhase = ''
      Rscript -e "
        source('libraries.R')
        mtcars <- readRDS('${mtcars}/mtcars.rds')
        mtcars_am <- filter(mtcars, am == 1)
        saveRDS(mtcars_am, 'mtcars_am.rds')"
    '';
  };

  mtcars_head = makeRDerivation {
    name = "mtcars_head";
    buildInputs = defaultBuildInputs;
    configurePhase = defaultConfigurePhase;
    buildPhase = ''
      Rscript -e "
        source('libraries.R')
        mtcars_am <- readRDS('${mtcars_am}/mtcars_am.rds')
        mtcars_head <- my_head(mtcars_am)
        saveRDS(mtcars_head, 'mtcars_head.rds')"
    '';
  };

  mtcars_tail = makeRDerivation {
    name = "mtcars_tail";
    buildInputs = defaultBuildInputs;
    configurePhase = defaultConfigurePhase;
    buildPhase = ''
      Rscript -e "
        source('libraries.R')
        mtcars_head <- readRDS('${mtcars_head}/mtcars_head.rds')
        mtcars_tail <- tail(mtcars_head)
        saveRDS(mtcars_tail, 'mtcars_tail.rds')"
    '';
  };

  mtcars_mpg = makeRDerivation {
    name = "mtcars_mpg";
    buildInputs = default2BuildInputs;
    configurePhase = default2ConfigurePhase;
    buildPhase = ''
      Rscript -e "
        source('libraries.R')
        mtcars_tail <- readRDS('${mtcars_tail}/mtcars_tail.rds')
        mtcars_mpg <- select(mtcars_tail, mpg)
        saveRDS(mtcars_mpg, 'mtcars_mpg.rds')"
    '';
  };

  page = defaultPkgs.stdenv.mkDerivation {
    name = "page";
    src = defaultPkgs.lib.fileset.toSource {
      root = ./.;
      fileset = defaultPkgs.lib.fileset.unions [ ./page.qmd ./content.qmd ./images ];
    };
    buildInputs = quarto-envBuildInputs;
    configurePhase = quarto-envConfigurePhase;
    buildPhase = ''
  mkdir home
  export HOME=$PWD/home
  substituteInPlace page.qmd --replace-fail 'rxp_read("mtcars_head")' 'rxp_read("${mtcars_head}/mtcars_head.rds")'
  substituteInPlace page.qmd --replace-fail 'rxp_read("mtcars_tail")' 'rxp_read("${mtcars_tail}/mtcars_tail.rds")'
  substituteInPlace page.qmd --replace-fail 'rxp_read("mtcars_mpg")' 'rxp_read("${mtcars_mpg}/mtcars_mpg.rds")'
  quarto render page.qmd --output-dir $out
    '';
  };

  # Generic default target that builds all derivations
  allDerivations = defaultPkgs.symlinkJoin {
    name = "all-derivations";
    paths = with builtins; attrValues { inherit mtcars mtcars_am mtcars_head mtcars_tail mtcars_mpg page; };
  };

in
{
  inherit mtcars mtcars_am mtcars_head mtcars_tail mtcars_mpg page;
  default = allDerivations;
}
