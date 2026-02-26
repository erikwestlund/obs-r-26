scaffold()

required_packages <- c(
  "Strategus",
  "CohortGenerator",
  "CohortDiagnostics",
  "CohortIncidence",
  "Characterization",
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
inst_folder <- file.path(study_folder, "inst")
settings_folder <- file.path(study_folder, "inst", "settings")
dir.create(settings_folder, recursive = TRUE, showWarnings = FALSE)

cohort_registry <- readr::read_csv(
  file.path(inst_folder, "Cohorts.csv"),
  show_col_types = FALSE
)

read_text <- function(path) {
  paste(readLines(path, warn = FALSE), collapse = "\n")
}

cohort_definition_set <- data.frame(
  cohortId = cohort_registry$cohort_id,
  cohortName = cohort_registry$cohort_name,
  sql = vapply(
    cohort_registry$sql_file,
    function(x) read_text(file.path(inst_folder, x)),
    character(1)
  ),
  json = vapply(
    cohort_registry$json_file,
    function(x) {
      if (is.na(x) || !nzchar(x)) {
        return(NA_character_)
      }
      read_text(file.path(inst_folder, x))
    },
    character(1)
  ),
  stringsAsFactors = FALSE
)

cg_module <- CohortGeneratorModule$new()
cd_module <- CohortDiagnosticsModule$new()
ci_module <- CohortIncidenceModule$new()
characterization_module <- CharacterizationModule$new()

cohort_definition_shared_resource <- cg_module$createCohortSharedResourceSpecifications(
  cohortDefinitionSet = cohort_definition_set
)

cohort_generator_module_specifications <- cg_module$createModuleSpecifications(
  generateStats = TRUE
)

cohort_diagnostics_module_specifications <- cd_module$createModuleSpecifications(
  runInclusionStatistics = TRUE,
  runIncludedSourceConcepts = TRUE,
  runOrphanConcepts = TRUE,
  runTimeSeries = FALSE,
  runVisitContext = TRUE,
  runBreakdownIndexEvents = TRUE,
  runIncidenceRate = TRUE,
  runCohortRelationship = TRUE,
  runTemporalCohortCharacterization = TRUE
)

targets <- list(
  CohortIncidence::createCohortRef(id = 101, name = "Celecoxib"),
  CohortIncidence::createCohortRef(id = 102, name = "Diclofenac")
)

outcomes <- list(
  CohortIncidence::createOutcomeDef(id = 1, name = "GI bleed", cohortId = 201, cleanWindow = 9999)
)

tars <- list(
  CohortIncidence::createTimeAtRiskDef(id = 1, startWith = "start", endWith = "end"),
  CohortIncidence::createTimeAtRiskDef(id = 2, startWith = "start", endWith = "start", endOffset = 365)
)

incidence_analysis <- CohortIncidence::createIncidenceAnalysis(
  targets = c(101, 102),
  outcomes = c(1),
  tars = c(1, 2)
)

ir_design <- CohortIncidence::createIncidenceDesign(
  targetDefs = targets,
  outcomeDefs = outcomes,
  tars = tars,
  analysisList = list(incidence_analysis),
  strataSettings = CohortIncidence::createStrataSettings(
    byYear = TRUE,
    byGender = TRUE
  )
)

cohort_incidence_module_specifications <- ci_module$createModuleSpecifications(
  irDesign = ir_design$toList()
)

characterization_module_specifications <- characterization_module$createModuleSpecifications(
  targetIds = c(101, 102),
  outcomeIds = 201
)

analysis_specifications <- createEmptyAnalysisSpecificiations() |>
  addSharedResources(cohort_definition_shared_resource) |>
  addModuleSpecifications(cohort_generator_module_specifications) |>
  addModuleSpecifications(cohort_diagnostics_module_specifications) |>
  addModuleSpecifications(cohort_incidence_module_specifications) |>
  addModuleSpecifications(characterization_module_specifications)

analysis_spec_path <- file.path(settings_folder, "gibleedAnalysisSpecifications.json")

ParallelLogger::saveSettingsToJson(
  object = analysis_specifications,
  fileName = analysis_spec_path
)

message("Saved analysis specifications to: ", analysis_spec_path)
