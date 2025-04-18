% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/parse_pypkgs.R
\name{adjust_imports}
\alias{adjust_imports}
\title{Adjust Python import statements}
\usage{
adjust_imports(old_import, new_import)
}
\arguments{
\item{old_import}{A character string representing the import statement to
be replaced. For example, \code{"import pillow"}.}

\item{new_import}{A character string representing the new import statement
to replace with. For example, \code{"from PIL import Image"}.}
}
\value{
No return value; the function performs in-place
modifications of the files.
}
\description{
When calling \code{rixpress()}, a file containing Python import statements is
automatically generated inside the \verb{_rixpress} folder. For example, if the
\code{numpy} package is needed, the file will include a line like \code{"import numpy"}.
However, Python programmers often write \code{"import numpy as np"} instead.
}
\details{
In some cases, the correct import statement is entirely different. For example,
for the \code{pillow} package, the generated file will contain \code{"import pillow"},
which is incorrect—Python code should import from the \code{PIL} namespace instead,
e.g., \code{"from PIL import Image"}.

Because these adjustments cannot be automated reliably, the \code{adjust_imports()}
function allows you to search and replace import statements programmatically.
It reads each file in the \verb{_rixpress} folder, performs the replacement,
and writes the modified content back to the file.
}
\examples{
\dontrun{
adjust_imports("import pillow", "from PIL import Image")
}
}
