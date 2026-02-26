# This script mirrors the Strategus "Creating Analysis Specification" workflow
# using a small, reproducible Eunomia-backed practice run.
#
# Local docs for this module:
# - modules/05_strategus-intro/strategus-intro.qmd
#
# Strategus reference docs used here:
# - https://ohdsi.github.io/Strategus/articles/IntroductionToStrategus.html
# - https://ohdsi.github.io/Strategus/articles/CreatingAnalysisSpecification.html
# - https://ohdsi.github.io/Strategus/articles/ExecuteStrategus.html

# 1) Verify required packages are installed ------------------------------------
# Keep installation out of the script; dependencies should come from renv so
# runs are reproducible across machines.
requiredPackages <- c(
  "Strategus",
  "Eunomia",
  "CohortGenerator",
  "CohortDiagnostics",
  "ParallelLogger"
)

missingPackages <- requiredPackages[!vapply(requiredPackages, requireNamespace, logical(1), quietly = TRUE)]

if (length(missingPackages) > 0) {
  stop(
    paste0(
      "Missing required packages: ",
      paste(missingPackages, collapse = ", "),
      ". Install dependencies first (for example with renv::restore())."
    )
  )
}

# DatabaseConnector depends on rJava; on Linux we may need to point R to JVM.
if (Sys.getenv("JAVA_HOME") == "" && dir.exists("/usr/lib/jvm/java-25-openjdk")) {
  Sys.setenv(JAVA_HOME = "/usr/lib/jvm/java-25-openjdk")
}

if (nzchar(Sys.getenv("JAVA_HOME"))) {
  jvmLib <- file.path(Sys.getenv("JAVA_HOME"), "lib", "server")
  Sys.setenv(LD_LIBRARY_PATH = paste(jvmLib, Sys.getenv("LD_LIBRARY_PATH"), sep = ":"))
}

library(Strategus)
library(Eunomia)

# 2) Create a clean output area for this practice run --------------------------
practiceFolder <- "modules/05_strategus-intro/strategus-practice"
dir.create(practiceFolder, recursive = TRUE, showWarnings = FALSE)

# 3) Load cohort definitions from Strategus test assets ------------------------
# This is the same cohort set used in Strategus examples and is convenient for
# learning module assembly before swapping in your own study assets.
cohortDefinitionSet <- CohortGenerator::getCohortDefinitionSet(
  settingsFileName = "testdata/Cohorts.csv",
  jsonFolder = "testdata/cohorts",
  sqlFolder = "testdata/sql",
  packageName = "Strategus"
)

# Print all cohort IDs/names as a tibble so print(n = Inf) works as expected.
cohortDefinitionSet |>
  dplyr::select(cohortId, cohortName) |>
  tibble::as_tibble() |>
  print(n = Inf)

# 4) Relabel cohorts for classroom clarity ------------------------------------
# Prefixing names helps distinguish practice artifacts from real study outputs.
cohortDefinitionSet <- cohortDefinitionSet |>
  dplyr::mutate(cohortName = paste0("Practice - ", .data$cohortName))

cohortDefinitionSet |>
  dplyr::select(cohortId, cohortName) |>
  tibble::as_tibble() |>
  print(n = Inf)

# 5) Assemble Strategus module specifications ---------------------------------
# Idiom: instantiate modules, create shared resources, then add module specs.
cgModule <- CohortGeneratorModule$new()
cdModule <- CohortDiagnosticsModule$new()

cohortDefinitionSharedResource <- cgModule$createCohortSharedResourceSpecifications(
  cohortDefinitionSet = cohortDefinitionSet
)

cohortGeneratorModuleSpecifications <- cgModule$createModuleSpecifications(
  generateStats = TRUE
)

cohortDiagnosticsModuleSpecifications <- cdModule$createModuleSpecifications(
  runInclusionStatistics = TRUE,
  runIncludedSourceConcepts = TRUE,
  runOrphanConcepts = FALSE,
  runTimeSeries = FALSE,
  runVisitContext = TRUE,
  runBreakdownIndexEvents = TRUE,
  runIncidenceRate = TRUE,
  runCohortRelationship = FALSE,
  runTemporalCohortCharacterization = FALSE
)

# 6) Compose and save analysis specifications ---------------------------------
analysisSpecifications <- createEmptyAnalysisSpecificiations() |>
  addSharedResources(cohortDefinitionSharedResource) |>
  addModuleSpecifications(cohortGeneratorModuleSpecifications) |>
  addModuleSpecifications(cohortDiagnosticsModuleSpecifications)

ParallelLogger::saveSettingsToJson(
  object = analysisSpecifications,
  fileName = file.path(practiceFolder, "practiceAnalysisSpecifications.json")
)

# 7) Create and save execution settings for Eunomia ----------------------------
# Eunomia uses the "main" schema for both CDM and work schema in this example.
connectionDetails <- getEunomiaConnectionDetails()

executionSettings <- createCdmExecutionSettings(
  workDatabaseSchema = "main",
  cdmDatabaseSchema = "main",
  cohortTableNames = CohortGenerator::getCohortTableNames(),
  workFolder = file.path(practiceFolder, "work_folder"),
  resultsFolder = file.path(practiceFolder, "results_folder"),
  minCellCount = 5
)

ParallelLogger::saveSettingsToJson(
  object = executionSettings,
  fileName = file.path(practiceFolder, "eunomiaExecutionSettings.json")
)

# 8) Execute the pipeline and list artifacts -----------------------------------
execute(
  connectionDetails = connectionDetails,
  analysisSpecifications = analysisSpecifications,
  executionSettings = executionSettings
)

list.files(practiceFolder, recursive = TRUE)
