if (!requireNamespace("renv", quietly = TRUE)) {
  message("renv not installed. Installing renv.")
  install.packages("renv")
}

message("Working directory: ", getwd())

# This file is the main place to manage the project environment.
# renv will still scan the whole project recursively when snapshot() runs.
# The default implicit scan looks for patterns like library(pkg), require(pkg),
# and pkg::fun(). You can inspect that with renv::dependencies().

# Initialize a renv project the first time you run this demo.
if (!file.exists("renv.lock")) {
  renv::init()
}

# Show the current project state and what renv thinks this project depends on.
renv::status()
renv::dependencies()

# Install OHDSI packages directly from GitHub.
renv::install("OHDSI/Strategus")
renv::install("OHDSI/CohortGenerator")

# Important distinction:
# - renv::install("OHDSI/Strategus") puts Strategus in the project library
# - renv::snapshot() decides whether Strategus belongs in renv.lock
# Installing from GitHub is not enough by itself for an implicit snapshot.
# We also reference the packages in project code so renv records them.
cohort_table_names <- CohortGenerator::getCohortTableNames()

results_settings <- Strategus::createResultsDataModelSettings(
  resultsDatabaseSchema = "study_results",
  resultsFolder = "demo-results"
)

print(cohort_table_names)
print(results_settings)

# If you wanted every installed package locked regardless of usage, use
# renv::snapshot(type = "all") instead.
# Freeze the environment into renv.lock.
renv::snapshot(prompt = FALSE)

message("Snapshot written to: ", file.path(getwd(), "renv.lock"))
