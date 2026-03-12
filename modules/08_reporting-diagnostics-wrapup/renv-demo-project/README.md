# renv demo project

Open `renv-demo-project.Rproj` in RStudio, then run `RenvManagement.R` line by line.

This project is intentionally small and is only meant to demonstrate the basic
`renv` workflow:

1. initialize a project library
2. install one package
3. snapshot the environment
4. inspect `renv.lock`
5. optionally run a restore drill

Note: `renv::snapshot()` normally records packages the project actually uses.
So if you want `dplyr` in `renv.lock`, do not just install it - also reference it in
project code with `library(dplyr)` or `dplyr::...`, or snapshot all installed packages.

By default, `renv` scans the whole project recursively, not just `RenvManagement.R`.
Use `renv::dependencies()` to see what it detected. If a real project gets large,
add `.renvignore` to exclude folders from dependency discovery.
