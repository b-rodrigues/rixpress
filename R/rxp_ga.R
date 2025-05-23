#' Run a pipeline on GitHub Actions
#' @family ci utilities
#' @details This function puts a `.yaml` file inside the `.github/workflows/`
#'   folder on the root of your project. This workflow file expects both
#'   scripts generated by `rxp_init()`, `gen-env.R` and `gen-pipeline.R` to be
#'   present. If that's not the case, edit the `.yaml` file accordingly. Build
#'   artifacts are archived and restored automatically between runs. Make sure
#'   to give read and write permissions to the GitHub Actions bot.
#' @return Nothing, copies file to a directory.
#' @export
#' @examples
#' \dontrun{
#'   rxp_ga()
#' }
rxp_ga <- function() {
  # is this being tested? If no, set the path to ".github/workflows"
  # if yes, set it to a temporary directory
  if (!identical(Sys.getenv("TESTTHAT"), "true")) {
    # Add an empty .gitignore file if there isn’t any

    if (file.exists(".gitignore")) {
      NULL
    } else {
      file.create(".gitignore")
    }

    path <- ".github/workflows"

    dir.create(path, recursive = TRUE)
  } else {
    path <- tempdir()
  }

  source <- system.file(
    file.path("extdata", "run-rxp-pipeline.yaml"),
    package = "rixpress",
    mustWork = TRUE
  )

  file.copy(source, path, overwrite = TRUE)

  # Generate dag.dot to view in CI
  dag_for_ci()

  if (identical(Sys.getenv("TESTTHAT"), "false")) {
    message("GitHub Actions workflow file saved to: ", path)
  }

  if (identical(Sys.getenv("TESTTHAT"), "true"))
    paste0(path, "/run-rxp-pipeline.yaml")
}
