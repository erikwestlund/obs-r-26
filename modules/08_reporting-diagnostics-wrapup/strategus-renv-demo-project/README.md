# strategus renv demo project

Open `strategus-renv-demo-project.Rproj` in RStudio, then run
`RenvManagement.R` line by line.

This project demonstrates the same `renv` workflow, but with OHDSI packages
installed from GitHub refs instead of a simple CRAN package.

The main teaching point is that `renv.lock` records both:

1. the package version
2. the remote source metadata needed to reinstall from GitHub

By default, `renv` scans the whole project recursively when you call
`renv::snapshot()`. `RenvManagement.R` is the main driver file here, but `renv`
will also consider other project files unless you exclude them with `.renvignore`.

Use `renv::dependencies()` to see what the project scan found.

Packages in this example:

- `OHDSI/Strategus`
- `OHDSI/CohortGenerator`
