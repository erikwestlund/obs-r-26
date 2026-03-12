if (!requireNamespace("renv", quietly = TRUE)) {
  message("renv not installed. Installing renv.")
  install.packages("renv")
}

message("Working directory: ", getwd())

# This file gives us one obvious place to manage the demo environment.
# But renv does not only look at this file.
# With the default implicit snapshot, it scans the whole project recursively
# for package references such as library(pkg), require(pkg), and pkg::fun().
# You can inspect what renv sees with renv::dependencies().

# Initialize a renv project the first time you run this demo.
if (!file.exists("renv.lock")) {
  renv::init()
}

# Restart the R session if renv asks you to.

# Check the current project state and the dependencies renv detected.
renv::status()
renv::dependencies()

# Important distinction:
# - renv::install("dplyr") puts dplyr in the project library
# - renv::snapshot() decides whether dplyr belongs in renv.lock
# With the default implicit snapshot, install alone is often not enough.
# To make dplyr show up in the lockfile, we both install it and reference it below.
renv::install("dplyr")

# Any explicit package usage in project code is enough for implicit snapshots.
# If this project grew larger, a .renvignore file would let us exclude folders.
# If you wanted every installed package locked regardless of usage, use
# renv::snapshot(type = "all") instead.
example_data <- dplyr::tibble(x = 1:3) |>
  dplyr::mutate(y = x + 1)

print(example_data)

# Freeze the current environment into renv.lock.
renv::snapshot()

message("Snapshot written to: ", file.path(getwd(), "renv.lock"))
