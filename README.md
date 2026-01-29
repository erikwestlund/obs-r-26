# Observational Research Methods in R

Course materials for working with the OHDSI/HADES ecosystem.

**Course Site:** [https://ohdsi-jhu.github.io/ME.250.788.SP26/](https://ohdsi-jhu.github.io/ME.250.788.SP26/)

## Sessions

### 1. The R Workflow

Environment, dependencies, and data foundations.

| Material | Rendered | Source |
|----------|----------|--------|
| Slides | [View](https://ohdsi-jhu.github.io/ME.250.788.SP26/slides/01_r-workflow/slides.html) | [Code](slides/01_r-workflow/slides.qmd) |
| Module | [View](https://ohdsi-jhu.github.io/ME.250.788.SP26/modules/01_r-workflow/r-foundations.html) | [Code](modules/01_r-workflow/r-foundations.qmd) |

### 2. Data Workflow

Tools, types, and data management with DatabaseConnector.

| Material | Rendered | Source |
|----------|----------|--------|
| Slides | [View](https://ohdsi-jhu.github.io/ME.250.788.SP26/slides/02_data-workflow/slides.html) | [Code](slides/02_data-workflow/slides.qmd) |
| Module | [View](https://ohdsi-jhu.github.io/ME.250.788.SP26/modules/02_data-workflow/data-workflow.html) | [Code](modules/02_data-workflow/data-workflow.qmd) |

### 3. OHDSI Basics (Provisional)

The Common Data Model and HADES ecosystem.

| Material | Rendered | Source |
|----------|----------|--------|
| Slides | [View](https://ohdsi-jhu.github.io/ME.250.788.SP26/slides/03_ohdsi-basics/slides.html) | [Code](slides/03_ohdsi-basics/slides.qmd) |
| Module | [View](https://ohdsi-jhu.github.io/ME.250.788.SP26/modules/03_ohdsi-basics/ohdsi-basics.html) | [Code](modules/03_ohdsi-basics/ohdsi-basics.qmd) |

## Other Topics

- Cohorts & Cohort Diagnostics
- Characterization
- CohortMethod: Population Level Effect Estimation
- Strategus

(This will be built out as the course progresses.)

## Structure

```
slides/          # Lecture slides (revealjs)
modules/         # Interactive notebooks (html)
scripts/         # Build scripts
docs/            # Rendered site (GitHub Pages)
```

## Building the Site

```r
source("scripts/render-site.R")
```

## Resources

- [OHDSI](https://ohdsi.org)
- [HADES](https://ohdsi.github.io/Hades/)
- [The Book of OHDSI](https://ohdsi.github.io/TheBookOfOhdsi/)
