# render-site.R
# Renders all course materials to docs/ for GitHub Pages
#
# Usage: Rscript scripts/render-site.R

project_root <- getwd()

cat("Rendering course materials to docs/\n")
cat("Project root:", project_root, "\n\n")

# Create docs directory structure
dir.create(file.path(project_root, "docs", "slides"), recursive = TRUE, showWarnings = FALSE)
dir.create(file.path(project_root, "docs", "modules"), recursive = TRUE, showWarnings = FALSE)

# Render index
cat("Rendering index.qmd...\n")
system("quarto render index.qmd --output-dir docs")

# Render slides
cat("\nRendering slides...\n")
slide_dirs <- list.dirs(file.path(project_root, "slides"), recursive = FALSE)
for (slide_dir in slide_dirs) {
  dir_name <- basename(slide_dir)
  cat("  -", dir_name, "\n")
  system(paste("quarto render", shQuote(slide_dir)))
}

# Render modules
cat("\nRendering modules...\n")
module_dirs <- list.dirs(file.path(project_root, "modules"), recursive = FALSE)
for (module_dir in module_dirs) {
  dir_name <- basename(module_dir)
  cat("  -", dir_name, "\n")
  system(paste("quarto render", shQuote(module_dir)))
}

# Create .nojekyll for GitHub Pages
file.create(file.path(project_root, "docs", ".nojekyll"))

cat("\nDone! Site rendered to docs/\n")
cat("\nFor GitHub Pages:\n")
cat("  1. Push to GitHub\n")
cat("  2. Settings > Pages > Source: Deploy from branch\n")
cat("  3. Branch: main, Folder: /docs\n")
