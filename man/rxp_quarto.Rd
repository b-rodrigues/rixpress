% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/derivs.R
\name{rxp_quarto}
\alias{rxp_quarto}
\title{Render a Quarto document as a Nix derivation}
\usage{
rxp_quarto(
  name,
  qmd_file,
  additional_files = "",
  nix_env = "default.nix",
  args = ""
)
}
\arguments{
\item{name}{Symbol, derivation name.}

\item{qmd_file}{Character, path to .qmd file.}

\item{additional_files}{Character vector, additional files to include.}

\item{nix_env}{Character, path to the Nix environment file, default is "default.nix".}

\item{args}{A character of additional arguments to be passed directly to
the \code{quarto} command.}
}
\value{
A list with elements: \code{name}, the \code{name} of the derivation,
\code{snippet}, the Nix boilerplate code, \code{type}, \code{additional_files} and \code{nix_env}.
}
\description{
Render a Quarto document as a Nix derivation
}
\details{
Detects \code{rxp_read("ref")} in the .qmd file and replaces with
derivation output paths.
}
\examples{
\dontrun{
  # `images` is a folder containing images to include in the Quarto doc
  rxp_quarto(name = report, qmd_file = "doc.qmd", additional_files = "images", args = "-- to typst")
}
}
