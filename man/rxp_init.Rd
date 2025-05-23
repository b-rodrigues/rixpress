% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/rxp_init.R
\name{rxp_init}
\alias{rxp_init}
\title{Initialize rixpress project}
\usage{
rxp_init(project_path = ".", skip_prompt = FALSE)
}
\arguments{
\item{project_path}{Character string specifying the project's path.}

\item{skip_prompt}{Logical. If TRUE, skips all confirmation prompts and proceeds
with initialization, useful on continuous integration. Defaults to FALSE.}
}
\value{
Logical. Returns TRUE if initialization was successful, FALSE if the
operation was cancelled by the user.
}
\description{
Generates \code{gen-env.R} and \code{gen-pipeline.R} scripts in the specified project
directory, after asking the user for confirmation. If the user declines, no
changes are made.
}
\details{
Creates (overwriting if they already exist):
\itemize{
\item \code{gen-env.R}: Script to define an execution environment with \code{{rix}}.
\item \code{gen-pipeline.R}: Defines a data pipeline with \code{{rixpress}}.
}
}
\examples{
# Default usage (will prompt before any action)
\dontrun{
  rxp_init()
}

}
\seealso{
Other utilities: 
\code{\link{print.derivation}()},
\code{\link{rxp_copy}()},
\code{\link{rxp_inspect}()},
\code{\link{rxp_list_logs}()},
\code{\link{rxp_load}()},
\code{\link{rxp_read}()}
}
\concept{utilities}
