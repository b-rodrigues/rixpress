
let
  pkgs = import (fetchTarball "https://github.com/rstats-on-nix/nixpkgs/archive/2025-03-10.tar.gz") {};
 
  rpkgs = builtins.attrValues {
    inherit (pkgs.rPackages) 
      dplyr
      janitor
      reticulate;
  };
  
  jlconf = pkgs.julia_110.withPackages [ 
      "Arrow"
      "DataFrames"
      "SparseArrays"
      "LinearAlgebra"
  ];
  
  system_packages = builtins.attrValues {
    inherit (pkgs) 
      R
      glibcLocales
      nix;
  };
  
  shell = pkgs.mkShell {
    LOCALE_ARCHIVE = if pkgs.system == "x86_64-linux" then "${pkgs.glibcLocales}/lib/locale/locale-archive" else "";
    LANG = "en_US.UTF-8";
    LC_ALL = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    
    buildInputs = [ rpkgs jlconf system_packages ];
    
  }; 
in
  {
    inherit pkgs shell;
  }
