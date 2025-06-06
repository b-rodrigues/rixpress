% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/rxp_read_load.R
\name{rxp_read}
\alias{rxp_read}
\title{Read output of a derivation}
\usage{
rxp_read(derivation_name, which_log = NULL, project_path = ".")
}
\arguments{
\item{derivation_name}{Character, the name of the derivation.}

\item{which_log}{Character, defaults to NULL. If NULL the most recent
build log is used. If a string is provided, it's used as a
regular expression to match against available log files.}

\item{project_path}{Character, defaults to ".".
Path to the root directory of the project.}
}
\value{
The derivation's output.
}
\description{
Reads the output of derivations in the current session,
returns a path if reading directly is not possible.
}
\details{
When \code{derivation_name} points to a single R object,
it gets read in the current session using \code{readRDS()}.
If it's a Python object and \code{{reticulate}} is available,
\code{reticulate::py_load_object()} is used. In case
the derivation is pointing to several outputs (which can
happen when building a Quarto document for example) or
neither \code{readRDS()} nor \code{reticulate::py_load_object()}
successfully read the object, the path to the object is
returned instead.
}
\examples{
\dontrun{
  mtcars <- rxp_read("mtcars")

  # Read from a specific build log
  mtcars <- rxp_read("mtcars", which_log = "2025-05-10")
}
}
\seealso{
Other utilities: 
\code{\link{print.derivation}()},
\code{\link{rxp_copy}()},
\code{\link{rxp_init}()},
\code{\link{rxp_inspect}()},
\code{\link{rxp_list_logs}()},
\code{\link{rxp_load}()}
}
\concept{utilities}
