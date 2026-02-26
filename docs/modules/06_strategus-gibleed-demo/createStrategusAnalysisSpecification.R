# =============================================================================
# Creating a Strategus Analysis Specification: GI Bleed Example
# =============================================================================
#
# Study question:
#   What is the risk of gastrointestinal (GI) bleed in new users of celecoxib
#   compared to new users of diclofenac?
#
# This script follows the three-step pattern from the "Creating Analysis
# Specification" walkthrough:
#   Step 1: Load cohorts and shared assets
#   Step 2: Instantiate modules and create module specifications
#   Step 3: Compose the full analysis specification and save as JSON
#
# Modules used (Part 1 scope -- no CohortMethod, SCCS, or PLP):
#   - CohortGeneratorModule
#   - CohortDiagnosticsModule
#   - CohortIncidenceModule
#   - CharacterizationModule
#
# Module reference docs:
#   https://ohdsi.github.io/Strategus/reference/CohortGeneratorModule.html
#   https://ohdsi.github.io/Strategus/reference/CohortDiagnosticsModule.html
#   https://ohdsi.github.io/Strategus/reference/CohortIncidenceModule.html
#   https://ohdsi.github.io/Strategus/reference/CharacterizationModule.html
#
# TIP: For any module, you can inspect ALL parameters and their defaults with:
#
#   formals(someModule$createModuleSpecifications)
#
# =============================================================================

library(Strategus)

dir.create("inst", recursive = TRUE, showWarnings = FALSE)


# =============================================================================
# STEP 1: Study Inputs -- Cohorts and Shared Resources
# =============================================================================
#
# Every Strategus study starts with cohort definitions. These become
# "sharedResources" in the analysis specification because any module
# (diagnostics, incidence, characterization, etc.) can reference them.
#
# We load the test cohorts bundled with the Strategus package:
#   1 -- Celecoxib
#   2 -- Diclofenac
#   3 -- GI bleed (outcome)
#   4 -- Celecoxib Age >= 30
#   5 -- Diclofenac Age >= 30
# -----------------------------------------------------------------------------

cohortDefinitionSet <- CohortGenerator::getCohortDefinitionSet(
	settingsFileName = "testdata/Cohorts.csv",
	jsonFolder = "testdata/cohorts",
	sqlFolder = "testdata/sql",
	packageName = "Strategus"
)

cohortDefinitionSet[, c("cohortId", "cohortName")]

# NOTE: Negative control outcomes are optional for this course workflow.
# The PDF includes them for CohortMethod/SCCS -- we skip them here.


# =============================================================================
# STEP 2: Assemble HADES Modules
# =============================================================================
#
# The pattern for every module is:
#   1. Instantiate the module object        (e.g., CohortGeneratorModule$new())
#   2. Create module specifications          (e.g., module$createModuleSpecifications(...))
#   3. Later, add to the analysis spec       (Step 3)
# -----------------------------------------------------------------------------


# --- 2.1 CohortGenerator Module ----------------------------------------------
# Ref: https://ohdsi.github.io/Strategus/reference/CohortGeneratorModule.html
#
# Generates cohorts in the CDM. The cohort definitions themselves go into
# sharedResources (not the module spec) so other modules can use them too.
#
# createModuleSpecifications defaults:
#   generateStats = TRUE   -- compute cohort inclusion/generation statistics

cgModule <- CohortGeneratorModule$new()

cohortDefinitionSharedResource <- cgModule$createCohortSharedResourceSpecifications(
	cohortDefinitionSet = cohortDefinitionSet
)

cohortGeneratorModuleSpecifications <- cgModule$createModuleSpecifications(
	generateStats = TRUE                    # default: TRUE
)


# --- 2.2 CohortDiagnostics Module --------------------------------------------
# Ref: https://ohdsi.github.io/Strategus/reference/CohortDiagnosticsModule.html
# See also: https://ohdsi.github.io/CohortDiagnostics/
#
# Runs a battery of diagnostic checks on each cohort.
#
# createModuleSpecifications defaults:
#   cohortIds                          = NULL  -- run on all cohorts (NULL = all)
#   runInclusionStatistics             = TRUE  -- inclusion rule pass/fail per step
#   runIncludedSourceConcepts          = TRUE  -- which source codes map into cohort
#   runOrphanConcepts                  = TRUE  -- nearby vocabulary concepts not included
#   runTimeSeries                      = FALSE -- cohort entry counts over calendar time
#   runVisitContext                    = TRUE  -- what visit types entries occur in
#   runBreakdownIndexEvents            = TRUE  -- concept-level breakdown of index events
#   runIncidenceRate                   = TRUE  -- incidence rate over time
#   runCohortRelationship              = TRUE  -- temporal overlap between cohorts
#   runTemporalCohortCharacterization  = TRUE  -- feature distributions at time windows
#   temporalCovariateSettings          = <module default covariate settings>
#   minCharacterizationMean            = 0.01  -- minimum mean for reporting features
#   irWashoutPeriod                    = 0     -- washout for incidence rate calculation

cdModule <- CohortDiagnosticsModule$new()

cohortDiagnosticsModuleSpecifications <- cdModule$createModuleSpecifications(
	cohortIds = NULL,                           # default: NULL (all cohorts)
	runInclusionStatistics = TRUE,              # default: TRUE
	runIncludedSourceConcepts = TRUE,           # default: TRUE
	runOrphanConcepts = TRUE,                   # default: TRUE
	runTimeSeries = FALSE,                      # default: FALSE
	runVisitContext = TRUE,                     # default: TRUE
	runBreakdownIndexEvents = TRUE,             # default: TRUE
	runIncidenceRate = TRUE,                    # default: TRUE
	runCohortRelationship = TRUE,               # default: TRUE
	runTemporalCohortCharacterization = TRUE,   # default: TRUE
	minCharacterizationMean = 0.01,             # default: 0.01
	irWashoutPeriod = 0                         # default: 0
	# temporalCovariateSettings = <module default covariate settings>
)


# --- 2.3 CohortIncidence Module -----------------------------------------------
# Ref: https://ohdsi.github.io/Strategus/reference/CohortIncidenceModule.html
# See also: https://ohdsi.github.io/CohortIncidence/
#
# Computes incidence rates for target cohorts x outcome x time-at-risk windows.
#
# createModuleSpecifications defaults:
#   irDesign = NULL  -- you MUST supply this; no meaningful default
#
# The design choices live in the sub-objects (targets, outcomes, TARs, strata).
# Sub-object docs:
#   https://ohdsi.github.io/CohortIncidence/reference/createOutcomeDef.html
#   https://ohdsi.github.io/CohortIncidence/reference/createTimeAtRiskDef.html
#   https://ohdsi.github.io/CohortIncidence/reference/createStrataSettings.html
#   https://ohdsi.github.io/CohortIncidence/reference/createCohortRef.html
#   https://ohdsi.github.io/CohortIncidence/reference/createIncidenceDesign.html
#
# createOutcomeDef defaults:
#   cohortId     = 0     -- must override with your outcome cohort ID
#   cleanWindow  = 0     -- days after event before person can have another
#                           (0 = count every event; 9999 = one event per person)
#   excludeCohortId = <empty>
#
# createTimeAtRiskDef defaults:
#   startWith   = "start"   -- anchor to cohort start
#   startOffset = 0         -- offset from start anchor
#   endWith     = "end"     -- anchor to cohort end
#   endOffset   = 0         -- offset from end anchor
#
# createStrataSettings defaults:
#   byAge    = FALSE
#   byGender = FALSE
#   byYear   = FALSE

ciModule <- CohortIncidenceModule$new()

targets <- list(
	CohortIncidence::createCohortRef(id = 1, name = "Celecoxib"),
	CohortIncidence::createCohortRef(id = 2, name = "Diclofenac"),
	CohortIncidence::createCohortRef(id = 4, name = "Celecoxib Age >= 30"),
	CohortIncidence::createCohortRef(id = 5, name = "Diclofenac Age >= 30")
)

outcomes <- list(
	CohortIncidence::createOutcomeDef(
		id = 1,
		name = "GI bleed",
		cohortId = 3,          # default: 0 (must override)
		cleanWindow = 9999     # default: 0 (we set 9999 = one event per person)
	)
)

tars <- list(
	CohortIncidence::createTimeAtRiskDef(
		id = 1,
		startWith = "start",   # default: "start"
		endWith = "end"        # default: "end"
	),
	CohortIncidence::createTimeAtRiskDef(
		id = 2,
		startWith = "start",   # default: "start"
		endWith = "start",     # override: anchor end to start
		endOffset = 365        # default: 0 (we set 365 for fixed 1-year window)
	)
)

incidenceAnalysis <- CohortIncidence::createIncidenceAnalysis(
	targets = c(1, 2, 4, 5),
	outcomes = c(1),
	tars = c(1, 2)
)

irDesign <- CohortIncidence::createIncidenceDesign(
	targetDefs = targets,
	outcomeDefs = outcomes,
	tars = tars,
	analysisList = list(incidenceAnalysis),
	strataSettings = CohortIncidence::createStrataSettings(
		byYear = TRUE,         # default: FALSE
		byGender = TRUE        # default: FALSE
	)
)

cohortIncidenceModuleSpecifications <- ciModule$createModuleSpecifications(
	irDesign = irDesign$toList()
)


# --- 2.4 Characterization Module ----------------------------------------------
# Ref: https://ohdsi.github.io/Strategus/reference/CharacterizationModule.html
# See also: https://ohdsi.github.io/Characterization/
#
# Produces baseline feature summaries for target cohorts with respect to the
# outcome.
#
# createModuleSpecifications defaults:
#   targetIds                      = <required>
#   outcomeIds                     = <required>
#   outcomeWashoutDays             = c(365)
#   minPriorObservation            = 365    -- days of required history
#   dechallengeStopInterval        = 30     -- days after exposure ends
#   dechallengeEvaluationWindow    = 30     -- window for dechallenge eval
#   riskWindowStart                = c(1, 1)
#   startAnchor                    = c("cohort start", "cohort start")
#   riskWindowEnd                  = c(0, 365)
#   endAnchor                      = c("cohort end", "cohort end")
#   minCharacterizationMean        = 0.01
#   covariateSettings              = <broad default: demographics, conditions,
#                                     drugs, procedures, measurements, etc.
#                                     at long-term (-365d) and short-term (-30d)>
#   caseCovariateSettings          = <during-exposure covariates>
#   casePreTargetDuration          = 365
#   casePostOutcomeDuration        = 365
#   includeTimeToEvent             = TRUE
#   includeDechallengeRechallenge  = TRUE
#   includeAggregateCovariate      = TRUE

cModule <- CharacterizationModule$new()

characterizationModuleSpecifications <- cModule$createModuleSpecifications(
	targetIds = c(1, 2),
	outcomeIds = 3,
	outcomeWashoutDays = c(365),                # default: c(365)
	minPriorObservation = 365,                  # default: 365
	dechallengeStopInterval = 30,               # default: 30
	dechallengeEvaluationWindow = 30,           # default: 30
	riskWindowStart = c(1, 1),                  # default: c(1, 1)
	startAnchor = c("cohort start",             # default: c("cohort start",
	                "cohort start"),             #            "cohort start")
	riskWindowEnd = c(0, 365),                  # default: c(0, 365)
	endAnchor = c("cohort end",                 # default: c("cohort end",
	              "cohort end"),                 #            "cohort end")
	minCharacterizationMean = 0.01,             # default: 0.01
	casePreTargetDuration = 365,                # default: 365
	casePostOutcomeDuration = 365,              # default: 365
	includeTimeToEvent = TRUE,                  # default: TRUE
	includeDechallengeRechallenge = TRUE,       # default: TRUE
	includeAggregateCovariate = TRUE            # default: TRUE
	# covariateSettings     = <broad default: demographics, conditions, drugs,
	#                          procedures, measurements at -365d and -30d windows>
	# caseCovariateSettings = <during-exposure covariates: conditions, drugs,
	#                          procedures, devices, measurements, observations>
)


# =============================================================================
# STEP 3: Compose and Save the Analysis Specification JSON
# =============================================================================
#
# Composition order:
#   1. Start with an empty specification
#   2. Add shared resources (cohort definitions)
#   3. Add each module specification
#   4. Save to JSON with ParallelLogger
#
# The resulting JSON is the primary design artifact -- it can be:
#   - Version-controlled and diffed
#   - Reviewed without database access
#   - Executed later at any OMOP CDM site
# -----------------------------------------------------------------------------

analysisSpecifications <- createEmptyAnalysisSpecifications() |>
	addSharedResources(cohortDefinitionSharedResource) |>
	addModuleSpecifications(cohortGeneratorModuleSpecifications) |>
	addModuleSpecifications(cohortDiagnosticsModuleSpecifications) |>
	addModuleSpecifications(cohortIncidenceModuleSpecifications) |>
	addModuleSpecifications(characterizationModuleSpecifications)

ParallelLogger::saveSettingsToJson(
	object = analysisSpecifications,
	fileName = "inst/studyAnalysisSpecification.json"
)

message("Analysis specification saved to: inst/studyAnalysisSpecification.json")
