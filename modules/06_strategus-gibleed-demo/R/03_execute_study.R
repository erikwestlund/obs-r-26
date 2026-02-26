scaffold()

required_packages <- c(
  "Strategus",
  "Eunomia",
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

analysis_spec_path <- file.path(settings_folder, "gibleedAnalysisSpecifications.json")
execution_settings_path <- file.path(settings_folder, "eunomiaExecutionSettings.json")

if (!file.exists(analysis_spec_path)) {
  stop("Missing analysis spec JSON. Run R/01_build_analysis_specification.R first.")
}

if (!file.exists(execution_settings_path)) {
  stop("Missing execution settings JSON. Run R/02_create_execution_settings_eunomia.R first.")
}

analysis_specifications <- ParallelLogger::loadSettingsFromJson(fileName = analysis_spec_path)
execution_settings <- ParallelLogger::loadSettingsFromJson(fileName = execution_settings_path)

connection_details <- Eunomia::getEunomiaConnectionDetails()

execute(
  connectionDetails = connection_details,
  analysisSpecifications = analysis_specifications,
  executionSettings = execution_settings
)

list.files(file.path(study_folder, "demo-output"), recursive = TRUE)
