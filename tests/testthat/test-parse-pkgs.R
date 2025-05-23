# Helper function to create a temporary Nix file
create_temp_nix <- function(content, project_path) {
  nix_file_path <- file.path(project_path, "temp_default.nix")
  writeLines(content, nix_file_path)
  return("temp_default.nix")
}

test_that("parse_packages handles various formats and edge cases", {
  path_tmpdir <- tempdir()
  dir.create(path_tmpdir, showWarnings = FALSE)
  on.exit(unlink(path_tmpdir, recursive = TRUE), add = TRUE, after = TRUE)

  nix_content1 <- c(
    "let",
    "  rpkgs = builtins.attrValues {",
    "    inherit (pkgs.rPackages);",
    "    tidyr",
    "    dplyr;",
    "  };",
    "in {}"
  )
  nix_file1 <- create_temp_nix(nix_content1, path_tmpdir)
  pkgs1 <- parse_packages(nix_file1, path_tmpdir, "rpkgs", transform_r)
  expect_equal(sort(pkgs1), c("dplyr", "tidyr"))

  nix_content2 <- c(
    "let",
    "  pyconf = builtins.attrValues {",
    "    inherit (pkgs.python312Packages);",
    "    pandas",
    "    numpy",
    "    scikit-learn;",
    "  };",
    "in {}"
  )
  nix_file2 <- create_temp_nix(nix_content2, path_tmpdir)
  pkgs2 <- parse_packages(nix_file2, path_tmpdir, "pyconf")
  expect_equal(sort(pkgs2), c("numpy", "pandas", "scikit-learn"))

  pkgs3 <- parse_packages(nix_file1, path_tmpdir, "nonexistent_block")
  expect_null(pkgs3)

  nix_content4 <- c(
    "let",
    "  rpkgs = builtins.attrValues {",
    "    dplyr"
    # Missing "};"
  )
  nix_file4 <- create_temp_nix(nix_content4, path_tmpdir)
  expect_error(
    parse_packages(nix_file4, path_tmpdir, "rpkgs"),
    "Could not find the end of the rpkgs block"
  )

  nix_content5 <- c(
    "let",
    "  rpkgs = builtins.attrValues {",
    "    inherit (pkgs.rPackages);",
    "  };",
    "in {}"
  )
  nix_file5 <- create_temp_nix(nix_content5, path_tmpdir)
  pkgs5 <- parse_packages(nix_file5, path_tmpdir, "rpkgs")
  expect_equal(pkgs5, character(0))
})

test_that("generate_libraries_script handles additional files", {
  path_tmpdir <- tempdir()
  dir.create(path_tmpdir, showWarnings = FALSE)
  on.exit(unlink(path_tmpdir, recursive = TRUE), add = TRUE, after = TRUE)

  # Setup additional files
  func_r_path <- file.path(path_tmpdir, "functions.R")
  func_py_path <- file.path(path_tmpdir, "functions.py")
  other_file_path <- file.path(path_tmpdir, "data.csv")
  writeLines("my_r_func <- function() {}", func_r_path)
  writeLines("def my_py_func(): pass", func_py_path)
  writeLines("a,b\n1,2", other_file_path)

  # Case 1: R script with functions.R
  r_outfile1 <- file.path(path_tmpdir, "lib1.R")
  generate_libraries_script(
    packages = c("dplyr"),
    additional_files = c(func_r_path, other_file_path), # Use full paths
    outfile = r_outfile1,
    import_formatter = import_formatter_r,
    additional_file_pattern = "functions\\.[Rr]"
  )
  lines1 <- readLines(r_outfile1)
  expect_equal(lines1, c("library(dplyr)", "my_r_func <- function() {}"))

  # Case 2: Python script with functions.py
  py_outfile1 <- file.path(path_tmpdir, "lib1.py")
  generate_libraries_script(
    packages = c("pandas"),
    additional_files = c(func_py_path, other_file_path), # Use full paths
    outfile = py_outfile1,
    import_formatter = import_formatter_py,
    additional_file_pattern = "functions\\.py"
  )
  lines2 <- readLines(py_outfile1)
  expect_equal(lines2, c("import pandas", "def my_py_func(): pass"))

  # Case 3: No matching additional files
  r_outfile2 <- file.path(path_tmpdir, "lib2.R")
  generate_libraries_script(
    packages = c("tidyr"),
    additional_files = c(other_file_path), # Use full path
    outfile = r_outfile2,
    import_formatter = import_formatter_r,
    additional_file_pattern = "functions\\.[Rr]"
  )
  lines3 <- readLines(r_outfile2)
  expect_equal(lines3, "library(tidyr)")

  # Case 4: Empty additional files
  r_outfile3 <- file.path(path_tmpdir, "lib3.R")
  generate_libraries_script(
    packages = c("stringr"),
    additional_files = "",
    outfile = r_outfile3,
    import_formatter = import_formatter_r,
    additional_file_pattern = "functions\\.[Rr]"
  )
  lines4 <- readLines(r_outfile3)
  expect_equal(lines4, "library(stringr)")
})

test_that("adjust_py_packages works correctly", {
  pkgs_in <- c("pandas", "pip", "numpy", "scikit-learn", "ipykernel")
  pkgs_out <- adjust_py_packages(pkgs_in)
  expect_equal(sort(pkgs_out), c("numpy", "pandas", "pickle", "sklearn"))

  pkgs_in2 <- c("tensorflow")
  pkgs_out2 <- adjust_py_packages(pkgs_in2)
  expect_equal(sort(pkgs_out2), c("pickle", "tensorflow"))

  pkgs_in3 <- character(0)
  pkgs_out3 <- adjust_py_packages(pkgs_in3)
  expect_equal(sort(pkgs_out3), c("pickle"))
})

test_that("transform_r works correctly", {
  expect_equal(transform_r("data_table"), "data.table")
  expect_equal(transform_r("ggplot2"), "ggplot2")
  expect_equal(
    transform_r(c("data_table", "stringi")),
    c("data.table", "stringi")
  )
})

test_that("adjust_import modifies files correctly", {
  path_tmpdir <- tempdir()
  path_rixpress <- file.path(path_tmpdir, "_rixpress")
  dir.create(path_rixpress, recursive = TRUE)
  on.exit(unlink(path_tmpdir, recursive = TRUE), add = TRUE, after = TRUE)

  # Create dummy files
  file1_path <- file.path(path_rixpress, "lib1.py")
  file2_path <- file.path(path_rixpress, "lib2.py")
  file3_path <- file.path(path_rixpress, "other.txt")
  writeLines(c("import pandas", "import numpy"), file1_path)
  writeLines(c("import os", "import pandas"), file2_path)
  writeLines(c("some text"), file3_path)

  # Perform adjustment (need to temporarily set working directory)
  old_wd <- getwd()
  setwd(path_tmpdir)
  adjust_import("import pandas", "import pandas as pd")
  setwd(old_wd)

  # Check file contents
  lines1 <- readLines(file1_path)
  lines2 <- readLines(file2_path)
  lines3 <- readLines(file3_path)

  expect_equal(lines1, c("import pandas as pd", "import numpy"))
  expect_equal(lines2, c("import os", "import pandas as pd"))
  expect_equal(lines3, c("some text")) # Should not change other files

  # Test non-matching import
  setwd(path_tmpdir)
  adjust_import("import non_existent", "import something_else")
  setwd(old_wd)

  lines1_after <- readLines(file1_path)
  expect_equal(lines1_after, c("import pandas as pd", "import numpy")) # No change
})
