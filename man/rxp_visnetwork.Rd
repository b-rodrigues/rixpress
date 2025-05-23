% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/plot_dag.R
\name{rxp_visnetwork}
\alias{rxp_visnetwork}
\title{Create a Directed Acyclic Graph (DAG) representing the pipeline
using \code{{visNetwork}}}
\usage{
rxp_visnetwork(nodes_and_edges = get_nodes_edges())
}
\arguments{
\item{nodes_and_edges}{List, output of \code{get_nodes_edges()}.}
}
\value{
Nothing, this function opens a new tab in your browser with
the DAG generated using \code{{visNetwork}}.
}
\description{
Uses \code{{visNetwork}} to generate the plot. \code{{visNetwork}} is a
soft dependency of \code{{rixpress}} so you need to install it to use this
function.
}
\examples{
\dontrun{
  rxp_visnetwork()
}
}
\seealso{
Other visualisation functions: 
\code{\link{rxp_ggdag}()}
}
\concept{visualisation functions}
