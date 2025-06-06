% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/rxp_make.R
\name{rxp_make}
\alias{rxp_make}
\title{Build pipeline using Nix}
\usage{
rxp_make(verbose = FALSE, max_jobs = 1, cores = 1)
}
\arguments{
\item{verbose}{Logical, defaults to FALSE. Set to TRUE to see nix's
standard output, can be useful to check what is happening if the
build process takes long.}

\item{max_jobs}{Integer, number of derivations to be built in parallel.}

\item{cores}{Integer, number of cores a derivation can use during build.}
}
\value{
A character vector of paths to the built outputs.
}
\description{
Runs \code{nix-build} with a quiet flag, outputting to \verb{_rixpress/result}.
}
\examples{
\dontrun{
  # Build the pipeline with default settings
  rxp_make()

  # Build with verbose output and parallel execution
  rxp_make(verbose = TRUE, max_jobs = 4, cores = 2)
}
}
\seealso{
Other pipeline functions: 
\code{\link{rixpress}()}
}
\concept{pipeline functions}
