% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/make_derivation.R
\name{derive_r}
\alias{derive_r}
\title{derive_r Creates a Nix expression running an R function}
\usage{
derive_r(name, expr)
}
\arguments{
\item{name}{Symbol, name of the derivation.}

\item{expr}{R code to generate the expression.}

\item{output}{Character, a variable name to save the
output of the function expression}
}
\value{
A list of two elements, \code{name}, the \code{name} of the derivation,
and \code{snippet} the Nix boilerplate code.
}
\description{
derive_r Creates a Nix expression running an R function
}
\details{
At a basic level, \code{derive_r(mtcars_am, filter(mtcars, am == 1))}
is equivalent to \code{mtcars <- filter(mtcars, am == 1)}. \code{derive_r()} generates
the required Nix boilerplate to output a so-called "derivation" in Nix
jargon. A Nix derivation is a recipe that defines how to create an output
(in this case \code{mtcars_am}) including its dependencies, build steps,
and output paths.
}
\examples{
derive_r(mtcars_am, filter(mtcars, am == 1))
}
