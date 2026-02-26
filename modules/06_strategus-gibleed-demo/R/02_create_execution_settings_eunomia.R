scaffold()

required_packages <- c(
  "Strategus",
  "Eunomia",
  "CohortGenerator",
  "ParallelLogger"
)

missing_packages <- required_packages[
  !vapply(required_packages, requireNamespace, logical(1), quietly = TRUE)
]

if (length(missing_packages) > 0) {
  stop(
    paste0(
      "Missing required packages: ",
      paste(missing_packages, collapse = ", "),
      ". Install dependencies first (for example with renv::restore())."
    )
  )
}

library(Strategus)

study_folder <- file.path("modules", "06_strategus-gibleed-demo")
settings_folder <- file.path(study_folder, "inst", "settings")
output_folder <- file.path(study_folder, "demo-output")

dir.create(settings_folder, recursive = TRUE, showWarnings = FALSE)
dir.create(output_folder, recursive = TRUE, showWarnings = FALSE)

execution_settings <- createCdmExecutionSettings(
  workDatabaseSchema = "main",
  cdmDatabaseSchema = "main",
  cohortTableNames = CohortGenerator::getCohortTableNames(),
  workFolder = file.path(output_folder, "work_folder"),
  resultsFolder = file.path(output_folder, "results_folder"),
  minCellCount = 5
)

execution_settings_path <- file.path(settings_folder, "eunomiaExecutionSettings.json")

ParallelLogger::saveSettingsToJson(
  object = execution_settings,
  fileName = execution_settings_path
)

message("Saved execution settings to: ", execution_settings_path)
