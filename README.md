
# rixpress: Reproducible Analytical Pipelines with Nix

This R packages provides a framework for building multilanguage
reproducible analytical pipelines by leverarging Nix’s build automation
capabilities. It is heavily inspired by the R package `{targets}`. It
builds upon the `{rix}` package, which provides helper function to
define reproducible development environments as code using Nix ensuring
the pipeline runs in a fully reproducible Nix-managed environment.
`{rixpress}` only requires users to write a pipeline using familiar R
code.

For example, this R script defines a list of *derivations* defined by
functions prefixed with `rxp_*()`, which is then passed to `rixpress()`:

``` r
library(rixpress)

list(
  rxp_r_file(
    mtcars,
    'mtcars.csv',
    \(x) (read.csv(file = x, sep = "|"))
  ),

  rxp_r(
    mtcars_am,
    filter(mtcars, am == 1)
  ),

  rxp_r(
    mtcars_head,
    head(mtcars_am)
  ),

  rxp_r(
    mtcars_tail,
    tail(mtcars_head)
  ),

  rxp_r(
    mtcars_mpg,
    select(mtcars_tail, mpg)
  ),

  rxp_quarto(
    page,
    "page.qmd"
  )
) |>
  rixpress()
```

Running `rixpress()` generates a `pipeline.nix` file, which contains all
the build instructions of all the derivations and final outputs as Nix
code. It is possible to define derivations that run Python code as well,
and objects can be passed to and from R or Python by using `rxp_py2r()`
and `ryp_r2py()`. By default, calling `rixpress()` also builds the
pipeline, but it’s possible to only generate the `pipeline.nix` file and
then build the pipeline at a later stage using:

    rxp_make()

The build process assumes the presence of a `default.nix` file which
defines the computational environment the pipeline runs in; this
`default.nix` file can be generated by using the `{rix}` package. This
`default.nix` defines an environment with R, R packages (and also Python
and Python packages if needed), Quarto, and all required system-level
dependencies pinned to a specific date to ensure reproducibility.

In the example above, the first derivation loads `mtcars.csv` (it
actually should be a `.psv` file, since the data is separated by pipes
–`|`… why? just because–). Each output (e.g., `mtcars`, `mtcars_am`,
`mtcars_head`, `mtcars_tail`, `mtcars_mpg`, `page`) is built by Nix
within the environment defined by the `default.nix` file. Concretely,
`{rix}` made using Nix as a package manager easier for R users,
`{rixpress}` makes it now easy to use Nix as a build automation tool!

When you run `rixpress()`, a folder called `_rixpress/` gets also
generated which contains a file with a JSON representation of the
pipeline’s DAG (Directed Acyclic Graph). You can visualize the pipeline
using `plot_dag()`:

``` r
plot_dag()
```

<figure>
<img src="https://raw.githubusercontent.com/b-rodrigues/rixpress/refs/heads/master/dag.png" alt="DAG" />
<figcaption aria-hidden="true">
DAG
</figcaption>
</figure>

Because the pipeline is built using Nix, the outputs all get stored in
the so-called Nix store under `/nix/store`. It can be annoying to
retrieve objects from the Nix store so `{rixpress}` contains several
helper functions:

- `rxp_read("mtcars_mpg")` reads `mtcars_mpg` into memory;
- `rxp_load("mtcars_mpg")` loads them into the global environment.

For complex outputs such as documents, (for example the Quarto document
defined above, called `page`), `rxp_read("page")` returns its file path,
which you can open with `browseURL("path/to/page")`, or you can copy the
outputs from the `/nix/store/` into the current worknig directory using
`rxp_copy("page")`, and read it from there.

You can export the cache into a file and easily import it on another
machine (or on CI) to avoid having to rebuild everything from scratch
using `export_nix_archive()` and `import_nix_archive()` respectively.

`rixpress()` is very flexible; please consult [this
repository](https://github.com/b-rodrigues/rixpress_demos/tree/master)
which contains many different examples you can take inspiration from.

## Installation

### rix

`{rixpress}` builds on `{rix}`, so we highly recommend you start by
learning and using `{rix}` before trying your hand at `{rixpress}`. By
learning how to use `{rix}`, you’ll learn more about Nix, how to install
and use it, and will then be ready to use `{rixpress}`!

### Installing rixpress

Since there’s little point in installing `{rixpress}` if you don’t use
Nix, the ideal way to install `{rixpress}` is instead to use `{rix}` to
set up a reproducible environment that includes `{rixpress}` and the
other required dependencies for your project. Take a look at the
[introductory concepts
vignette](https://b-rodrigues.github.io/rixpress/articles/a-intro_concepts.html)
and [basic usage
vignette](https://b-rodrigues.github.io/rixpress/articles/b-basic_pipeline.html)
to get started!

That being said, `{rixpress}` is a regular R package, so you can install
it from GitHub directly (while it’s not on CRAN):

``` r
# Install remotes if you don’t have it
if (!require("remotes")) install.packages("remotes")

# Install the package from GitHub
remotes::install_github("b-rodrigues/rixpress")
```
