# rixpress: Reproducible Analytical Pipelines with Nix

This package provides a framework for building reproducible analytical pipelines using Nix, drawing inspiration from the R package `targets`. 
It uses a `default.nix` file generated by the R `rix` package to ensure a consistent environment, making your data analysis workflows fully reproducible and capable of supporting pipeline steps in multiple programming languages.

## Purpose

The goal is to create data analysis pipelines that are:

- **Fully Reproducible:** Work the same way across machines and over time.
- **Multi-Language:** Allow steps in R, Python, or other languages supported by Nix.
- **Inspired by targets:** Mimic its dependency tracking and task orchestration, enhanced by Nix’s deterministic builds.

By combining Nix’s reproducibility with a targets-like structure, you can rebuild every step of your analysis—data processing, modeling, reporting—exactly as intended, even years later or on different systems.

## How It Works

### Environment Setup with `default.nix`
- The `rix` package creates a `default.nix` file specifying your software environment (e.g., R version, packages).
- `{rixpress}` generates a `pipeline.nix` which builds a (potentially) polyglott data science project using Nix as the build automation tool.
- The `default.nix` generated by `{rix}` is used to provide the right environment to the pipeline.

### Pipeline Definition
- Define steps (derivations) in a `pipeline.nix` file, which can use R or other languages.
- Each derivation produces outputs like datasets or reports.

### Dependency Graph
- A `dag.json` file maps out the relationships between derivations.
- R scripts process this JSON to add dependency loading (e.g., `readRDS` calls) to `pipeline.nix`.

### Building the Pipeline
- Run `nix-build pipeline.nix` to execute the pipeline, storing outputs in the Nix store (e.g., `/nix/store/...`).

## Key Advantages of Using Nix

- **Complete Reproducibility:** Pins all dependencies to exact versions.
- **Multi-Language Support:** Unlike `targets`, it’s not limited to R.
- **Isolation:** Each step runs in a sandbox, avoiding system interference.
- **Portability:** Share your Nix files, and anyone with Nix can rebuild your work.

## Inspiration from `targets`

This package borrows from `targets`:

- **Dependency Tracking:** Ensures steps only rerun when inputs change.
- **Modularity:** Breaks workflows into reusable steps.
- **Automation:** Executes tasks in the right order.

Nix extends these ideas beyond R into a cross-language, reproducible framework.

## Installation

### Prerequisites

#### Install Nix
tbd

#### Install R
tbd

### Install from GitHub

To install this package directly from GitHub, use the `remotes` R package:

```r
# Install remotes if you don’t have it
if (!require("remotes")) install.packages("remotes")

# Install the package from GitHub
remotes::install_github("b-rodrigues/rixpress")
```

## Usage Example

### Define Your Pipeline in R

```r
# Create derivations
d1 <- mk_r(mtcars_am, filter(mtcars, am == 1))
d2 <- mk_r(mtcars_head, head(mtcars_am))

# Collect into a list
deriv_list <- list(d1, d2)

# Save or process further (e.g., generate pipeline.nix and dag.json)
```

### Build the Pipeline

Generate `pipeline.nix` and `dag.json` using provided scripts (e.g., `generate_dag.R`, `postprocess_nix.R`). Then run:

```bash
nix-build pipeline.nix
```

This builds all derivations, producing outputs in the Nix store.

## Contributing

TBD

