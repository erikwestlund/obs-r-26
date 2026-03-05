# Strategus GiBleed Demo Study Package

This module is structured like a small OHDSI study package so students can practice a realistic Strategus workflow.

## Folder layout

- `inst/Cohorts.csv`: cohort registry with semantic cohort IDs
- `inst/sql/sql_server/`: SQL cohort definitions
- `inst/cohorts/`: optional JSON cohort definitions (from ATLAS/WebAPI export, not from Eunomia)
- `R/01_build_analysis_specification.R`: builds and saves analysis specification JSON
- `R/02_create_execution_settings_eunomia.R`: builds and saves Eunomia execution settings JSON
- `R/03_execute_study.R`: runs `execute()` with saved JSON settings
- `strategus-gibleed-demo.R`: convenience script that runs all steps in order
- `inst/settings/`: generated JSON settings files

## Semantic cohort IDs used here

- `101`: Target - Celecoxib new users
- `102`: Comparator - Diclofenac new users
- `201`: Outcome - GI bleed

## Note on JSON cohort definitions

Eunomia provides CDM data, not ATLAS cohort definition JSON artifacts.
For this demo, cohorts are SQL-defined and `json_file` is optional (`NA`) in `inst/Cohorts.csv`.
If you want full JSON-backed cohorts, export them from ATLAS/WebAPI and place them in `inst/cohorts/`.

## Run order

1. Open `strategus-gibleed-demo.Rproj` or `strategus-gibleed-demo.code-workspace`
2. Run `R/01_build_analysis_specification.R`
3. Run `R/02_create_execution_settings_eunomia.R`
4. Run `R/03_execute_study.R`

Execution is optional for assignment workflows; creating valid analysis specification JSON is required.
