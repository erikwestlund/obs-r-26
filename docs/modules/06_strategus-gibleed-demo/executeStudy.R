# =============================================================================
# Execute the Strategus Analysis Specification on Eunomia
# =============================================================================
#
# This script:
#   1. Creates execution settings for the Eunomia test database
#   2. Loads the analysis specification JSON built by createStrategusAnalysisSpecification.R
#   3. Runs execute() to run all modules against Eunomia
#
# Prerequisites:
#   - Run createStrategusAnalysisSpecification.R first to generate the JSON
#   - Eunomia package must be installed
#
# Ref: https://ohdsi.github.io/Strategus/articles/ExecuteStrategus.html
# =============================================================================

library(Strategus)

dir.create("demo-output/work_folder", recursive = TRUE, showWarnings = FALSE)
dir.create("demo-output/results_folder", recursive = TRUE, showWarnings = FALSE)


# =============================================================================
# STEP 1: Create Execution Settings
# =============================================================================
#
# Execution settings tell Strategus WHERE and HOW to run -- separate from
# the analysis specification (WHAT to run).
#
# createCdmExecutionSettings defaults:
#   cohortTableNames    = CohortGenerator::getCohortTableNames(cohortTable = "cohort")
#   tempEmulationSchema = getOption("sqlRenderTempEmulationSchema")
#   logFileName         = file.path(resultsFolder, "strategus-log.txt")
#   minCellCount        = 5      -- suppress cell counts below this threshold
#   incremental         = TRUE   -- skip modules that already have results
#   maxCores            = parallel::detectCores()
#   modulesToExecute    = c()    -- empty = run all modules in the spec
# -----------------------------------------------------------------------------

executionSettings <- createCdmExecutionSettings(
	workDatabaseSchema = "main",                         # Eunomia schema
	cdmDatabaseSchema = "main",                          # Eunomia schema
	cohortTableNames = CohortGenerator::getCohortTableNames(
		cohortTable = "cohort"                              # default: "cohort"
	),
	workFolder = "demo-output/work_folder",
	resultsFolder = "demo-output/results_folder",
	minCellCount = 5,                                    # default: 5
	incremental = TRUE,                                  # default: TRUE
	maxCores = parallel::detectCores(),                  # default: all cores
	modulesToExecute = c()                               # default: c() (all modules)
)

# Optionally save execution settings to JSON for reproducibility
ParallelLogger::saveSettingsToJson(
	object = executionSettings,
	fileName = "inst/eunomiaExecutionSettings.json"
)


# =============================================================================
# STEP 2: Load the Analysis Specification
# =============================================================================

analysisSpecPath <- "inst/studyAnalysisSpecification.json"

if (!file.exists(analysisSpecPath)) {
	stop("Analysis specification not found. Run createStrategusAnalysisSpecification.R first.")
}

analysisSpecifications <- ParallelLogger::loadSettingsFromJson(
	fileName = analysisSpecPath
)


# =============================================================================
# STEP 3: Connect to Eunomia and Execute
# =============================================================================
#
# Eunomia provides a small, self-contained OMOP CDM for testing.
# execute() runs each module in the analysis specification in order.
# -----------------------------------------------------------------------------

connectionDetails <- Eunomia::getEunomiaConnectionDetails()

execute(
	connectionDetails = connectionDetails,
	analysisSpecifications = analysisSpecifications,
	executionSettings = executionSettings
)

message("Execution complete. Results in: demo-output/results_folder/")
list.files("demo-output/results_folder", recursive = TRUE)
