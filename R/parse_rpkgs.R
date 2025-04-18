#' Generate an R script with library calls from a default.nix file
#'
#' @param nix_file Path to the default.nix file (default: "default.nix")
#' @param additional_files Character vector, additional files to include. Custom
#'   functions must go into a script called "functions.R", and additional files
#'   that need to be accessible during the build process can be named anything.
#' @param project_path Path to root of project, typically "."
#' @return An R script to load the libraries inside of derivations.
#' @noRd
generate_r_libraries_from_nix <- function(
  nix_file,
  additional_files = "",
  project_path
) {
  packages <- parse_rpkgs(nix_file, project_path)
  if (is.null(packages)) {
    return(NULL)
  }

  nix_file_name <- gsub("[^a-zA-Z0-9]", "_", nix_file)
  nix_file_name <- sub("_nix$", "", nix_file_name)

  generate_r_libraries_script(
    packages,
    additional_files,
    file.path(
      project_path,
      "/_rixpress/",
      paste0(nix_file_name, "_libraries.R")
    )
  )
}

#' Helper function to add 'library()' to packages.
#'
#' @param nix_file Path to the default.nix file (default: "default.nix")
#' @param additional_files Character vector, additional files to include. Custom
#'   functions must go into a script called "functions.R", and additional files
#'   that need to be accessible during the build process can be named anything.
#' @param outfile Path to the output file, we recommend to leave the
#'   default `"_rixpress/libraries.R"`
#' @return A script to load the libraries inside of derivations.
#' @noRd
generate_r_libraries_script <- function(
  packages,
  additional_files = "",
  outfile
) {
  functions_R <- any(grepl("functions.(R|r)", additional_files))

  library_lines <- paste0("library(", packages, ")")

  if (!functions_R) {
    output <- library_lines
  } else if (functions_R) {
    functions_R_scripts <- Filter(
      \(x) (grepl("functions.(R|r)", x)),
      x = additional_files
    )
    list_functions_R_content <- lapply(functions_R_scripts, readLines)
    functions_R_content <- Reduce(f = append, x = list_functions_R_content)
    output <- append(library_lines, functions_R_content)
  }

  writeLines(output, outfile)
}

#' Extract R packages from a default.nix file
#'
#' @param nix_file Path to the default.nix file (default: "default.nix")
#' @param project_path Path to root of project, typically "."
#' @return List of R packages defined in the rpkgs block of a default.nix file
#' @noRd
parse_rpkgs <- function(nix_file, project_path) {
  # Read the file as lines
  lines <- readLines(file.path(project_path, nix_file))

  # Find the starting index of the rpkgs block
  start_idx <- grep("^\\s*rpkgs\\s*=\\s*builtins\\.attrValues\\s*\\{", lines)
  if (length(start_idx) == 0) {
    return(NULL)
  }
  start_idx <- start_idx[1]

  # Find the end of the rpkgs block (a line that starts with "};")
  end_idx <- grep("^\\s*\\};", lines)
  end_idx <- end_idx[end_idx > start_idx][1]
  if (is.na(end_idx)) {
    stop("Could not find the end of the rpkgs block")
  }

  # Extract lines within the block
  block_lines <- lines[(start_idx + 1):(end_idx - 1)]

  # Remove comments and trim white spaces
  block_lines <- gsub("#.*", "", block_lines)
  block_lines <- trimws(block_lines)

  # Remove any empty lines
  block_lines <- block_lines[block_lines != ""]

  # Remove the "inherit (pkgs.rPackages)" phrase if present
  block_lines <- gsub("inherit \\(pkgs\\.rPackages\\)", "", block_lines)

  # Remove semicolon characters
  block_lines <- gsub(";", "", block_lines)

  # Combine all lines into one string and split by whitespace
  packages <- unlist(strsplit(paste(block_lines, collapse = " "), "\\s+"))

  # In Nix, R packages use _ instead of ., so data_table needs to become
  # data.table

  packages <- gsub("_", ".", packages)

  # Remove empty strings if any
  packages[packages != ""]
}
