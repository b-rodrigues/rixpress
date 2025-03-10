#' Generate a DAG from a list of derivations
#'
#' Creates a JSON representation of a directed acyclic graph (DAG) based on dependencies
#' between derivations.
#'
#' @param drv_list A list of derivations, each with a `name` and `snippet`, output of drv_r().
#' @param output_file Path to the output JSON file. Defaults to "_rixpress/dag.json".
#' @importFrom jsonlite write_json
#' @return Writes a JSON file representing the DAG.
#' @export
generate_dag <- function(drv_list, output_file = "_rixpress/dag.json") {
  dir.create(dirname(output_file), recursive = TRUE, showWarnings = FALSE)

  n <- length(drv_list)
  dag <- vector("list", n)
  defined <- character(n)

  for (i in seq_along(drv_list)) {
    d <- drv_list[[i]]
    name <- d$name
    type <- d$type

    if (type == "drv_r") {
      snippet <- d$snippet
      # Extract the content inside the Rscript -e quotes (allowing for multiple lines)
      m <- regexec('Rscript -e \\"([\\s\\S]*?)\\"', snippet, perl = TRUE)
      match <- regmatches(snippet, m)
      block <- if (length(match[[1]]) > 1) match[[1]][2] else ""
      # Split the block into lines and find the first assignment line
      lines <- unlist(strsplit(block, "\n"))
      assignment_lines <- grep("<-", lines, value = TRUE)
      expr <- if (length(assignment_lines) > 0) trimws(assignment_lines[1]) else
        ""
      # Identify dependencies by finding all names in the expression that match previously defined derivations
      deps <- intersect(all.names(parse(text = expr)), defined[1:(i - 1)])
    } else if (type == "drv_quarto") {
      # Try both .qmd and .Qmd extensions
      qmd_file <- paste0(name, ".qmd")
      if (!file.exists(qmd_file)) {
        qmd_file <- paste0(name, ".Qmd")
        if (!file.exists(qmd_file)) {
          stop("Quarto file not found: ", name, ".qmd or ", name, ".Qmd")
        }
      }
      # Read the Quarto file
      qmd_content <- readLines(qmd_file, warn = FALSE)
      qmd_text <- paste(qmd_content, collapse = "\n")

      # Extract R code chunks (between ```{r} and ```)
      chunk_pattern <- "```\\{r\\}[\\s\\S]*?```"
      chunks <- regmatches(
        qmd_text,
        gregexpr(chunk_pattern, qmd_text, perl = TRUE)
      )[[1]]

      # Process each chunk to find drv_read() or drv_load() calls
      deps <- character(0)
      for (chunk in chunks) {
        # Remove the ```{r} and ``` delimiters
        code <- sub("```\\{r\\}\\s*", "", chunk)
        code <- sub("```\\s*$", "", code)

        # Match drv_read("name") or drv_load("name"), with or without rixpress::
        pattern <- "(rixpress::)?drv_(read|load)\\s*\\(\\s*['\"](\\w+)['\"]\\s*\\)"
        matches <- regmatches(code, gregexpr(pattern, code, perl = TRUE))[[1]]

        # Extract the dependency names (group 3 in the pattern)
        if (length(matches) > 0) {
          dep_names <- vapply(
            matches,
            function(m) {
              regmatches(m, regexec(pattern, m, perl = TRUE))[[1]][4]
            },
            character(1)
          )
          deps <- union(deps, dep_names)
        }
      }
      # Filter dependencies to only those previously defined
      deps <- intersect(deps, defined[1:(i - 1)])
    } else {
      stop("Unknown derivation type: ", type)
    }

    dag[[i]] <- list(deriv_name = name, depends = deps, type = type)
    defined[i] <- name
  }

  jsonlite::write_json(list(derivations = dag), output_file, pretty = TRUE)

  if (identical(Sys.getenv("TESTTHAT"), "true")) {
    output_file
  }
}
