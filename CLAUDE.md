# observational-research-methods-in-r

This file provides guidance to AI assistants working with this Framework project.
Edit the sections without regeneration markers freely - they won't be overwritten.


## Framework Environment <!-- @framework:regenerate -->

This project uses Framework for reproducible data analysis. **Every notebook and script
MUST begin with `scaffold()`** which initializes the environment.

### What scaffold() Does

When you call `scaffold()`, it automatically:

1. **Sets the working directory** to the project root (handles nested notebook execution)
2. **Loads environment variables** from `.env` (database credentials, API keys)
3. **Installs missing packages** listed in settings.yml
4. **Attaches packages** marked with `auto_attach: true` (see Packages section below)
5. **Sources all functions** from `functions/` directory - they are globally available
6. **Sets ggplot2 theme** to `theme_minimal()`

### CRITICAL RULES

**DO NOT** call `library()` for packages listed in the auto-attach section below.
They are already loaded by scaffold(). Calling library() again wastes time and clutters output.

**DO NOT** use `source()` to load functions from the functions/ directory.
They are auto-loaded by scaffold(). Just call them directly.


## Installed Packages <!-- @framework:regenerate -->

**Auto-attached** (loaded by scaffold): dplyr, ggplot2, tidyr, stringr, readr
**Installed** (call library() when needed): lubridate, glue, here

Add packages with `package_add("name")` or `package_add("name", auto_attach = TRUE)`.

## Data Management <!-- @framework:regenerate -->

**CRITICAL: All data operations MUST go through Framework functions.**
This ensures integrity tracking and reproducibility.

### Reading Data

**ALWAYS use `data_read()`:**

```r
# From data catalog (preferred)
survey <- data_read("inputs.raw.survey")

# Direct path
customers <- data_read("data/customers.csv")
```

**NEVER use these functions:**
- ❌ `read.csv()` - no tracking
- ❌ `read_csv()` - no tracking
- ❌ `readRDS()` - no tracking
- ❌ `read_excel()` - no tracking

If you see code using these functions, **replace it with `data_read()`**.

### Saving Data

**ALWAYS use `data_save()`:**

```r
# Save to intermediate (tracked, integrity-checked)
data_save(cleaned_df, "data/cleaned.csv")

# Save to final (locked, prevents accidental overwrites)
data_save(final_df, "data/analysis_ready.csv", locked = TRUE)
```

**NEVER use these functions:**
- ❌ `write.csv()` - no tracking
- ❌ `write_csv()` - no tracking
- ❌ `saveRDS()` - no tracking

### Directory Structure

| Purpose | Directory |
|---------|-----------|
| Course data | `data/` |
| Lecture slides | `slides/` |
| Assignments | `assignments/` |
| Course documents | `course_docs/` |


## Function Reference <!-- @framework:regenerate -->

### Data Functions

#### data_read(path)
Read data from catalog or file path. Supports CSV, RDS, Excel, Stata, SPSS, SAS.

```r
df <- data_read("inputs.raw.survey")      # From catalog
df <- data_read("inputs/raw/file.csv")    # Direct path
```

#### data_save(data, path, locked = FALSE)
Save data with integrity tracking.

```r
data_save(df, "inputs/intermediate/cleaned.csv")
data_save(df, "inputs/final/analysis_ready.csv", locked = TRUE)
```

### Cache Functions

#### cache_remember(name, expr)
Compute once, cache result. Use for expensive operations.

```r
model <- cache_remember("my_model", {
  # This only runs if cache doesn't exist or is expired
  train_expensive_model(data)
})
```

#### cache_get(name) / cache(name, value)
Manual cache read/write.

```r
cache("processed_data", large_dataframe)  # Write
df <- cache_get("processed_data")          # Read (NULL if missing)
```

### Output Functions

#### result_save(name, value, type)
Save analysis results with metadata.

```r
result_save("regression_model", model, type = "model")
result_save("summary_stats", stats_df, type = "table")
```

#### save_table(data, name, format = "csv")
Quick export to outputs/tables/.

```r
save_table(summary_df, "quarterly_summary")
save_table(report_df, "annual_report", format = "xlsx")
```

### Query Functions

#### query_get(sql, connection)
Execute SQL and return results.

```r
users <- query_get("SELECT * FROM users WHERE active = 1", "main_db")
```

### Notebook/Script Creation

#### make_notebook(name) / make_script(name)
Create new files from templates.

```r
make_notebook("01-data-cleaning")     # Creates notebooks/01-data-cleaning.qmd
make_script("data-processing")        # Creates scripts/data-processing.R
```


## Course Structure

This is a teaching/course project with the following layout:

- `slides/` - Lecture materials (Quarto revealjs format)
- `assignments/` - Student exercises and homework
- `modules/` - Course modules/lessons
- `course_docs/` - Syllabus, policies, schedules
- `data/` - Datasets for demonstrations and exercises
- `readings/` - Reading materials and references

### Creating Course Materials

```r
# Create a new lecture
make_notebook("lecture-01-intro", dir = "slides", stub = "revealjs")

# Create an assignment
make_notebook("hw-01-basics", dir = "assignments")
```


## Project Notes

*Add your project-specific notes, conventions, and documentation here.*
*This section is never modified by `ai_regenerate_context()`.*

