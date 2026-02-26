scaffold()

study_folder <- file.path("modules", "06_strategus-gibleed-demo")

source(file.path(study_folder, "R", "01_build_analysis_specification.R"))
source(file.path(study_folder, "R", "02_create_execution_settings_eunomia.R"))

run_execution <- TRUE

if (isTRUE(run_execution)) {
  source(file.path(study_folder, "R", "03_execute_study.R"))
}
