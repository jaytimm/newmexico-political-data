# ============================================================================
# Process ABQ Mayoral Candidate Questionnaire PDFs to Markdown
# ============================================================================
# This script uses Docling (via langchain-docling) to convert PDF questionnaire
# responses from the 2025 Albuquerque mayoral candidates into structured
# markdown format.
#
# Data source: data-raw/abq_mayor_2025_questionnaires/
# Output: data/abq_mayor_2025_questionnaires/
# ============================================================================

# Ensure we're in the project root directory (where data-raw/ exists)
if (!dir.exists("data-raw")) {
  # Get script location and navigate to project root
  this_file <- commandArgs(trailingOnly = FALSE)
  this_file <- sub("--file=", "", this_file[grepl("--file=", this_file)])
  if (length(this_file) > 0 && file.exists(this_file)) {
    script_dir <- dirname(normalizePath(this_file))
    project_root <- dirname(script_dir)
    if (dir.exists(file.path(project_root, "data-raw"))) {
      setwd(project_root)
      cat("Changed to project directory:", getwd(), "\n")
    }
  }
  if (!dir.exists("data-raw")) {
    stop("Could not find 'data-raw' directory. Please run this script from the project root.")
  }
}

# Install and load required packages
if (!require("pacman", quietly = TRUE)) {
  install.packages("pacman")
}

pacman::p_load(
  reticulate  # Python interface for R
)

# ============================================================================
# Setup Python Environment
# ============================================================================
# Use the docling environment (conda or venv) with langchain-docling installed
env_name <- "docling"
home_dir <- Sys.getenv("HOME")

# Get project root directory
project_root <- getwd()
if (!dir.exists("data-raw") && dir.exists("..")) {
  # Try parent directory
  if (dir.exists(file.path("..", "data-raw"))) {
    project_root <- normalizePath("..")
  }
}

# Try venv first (project-local, more reliable)
venv_path <- file.path(project_root, ".venv_docling", "bin", "python")
if (file.exists(venv_path)) {
  python_path <- venv_path
  cat("Using venv at:", python_path, "\n")
} else {
  # Try conda paths
  possible_paths <- c(
    file.path(home_dir, "miniconda3", "envs", env_name, "bin", "python"),
    file.path(home_dir, "anaconda3", "envs", env_name, "bin", "python"),
    file.path(home_dir, "conda", "envs", env_name, "bin", "python")
  )
  
  python_path <- NULL
  for (path in possible_paths) {
    if (file.exists(path)) {
      python_path <- path
      cat("Using conda environment at:", python_path, "\n")
      break
    }
  }
  
  # If not found, try to get from conda command
  if (is.null(python_path)) {
    conda_path <- tryCatch({
      system2("conda", c("run", "-n", env_name, "which", "python"), 
              stdout = TRUE, stderr = FALSE)
    }, error = function(e) NULL)
    
    if (!is.null(conda_path) && length(conda_path) > 0 && file.exists(conda_path[1])) {
      python_path <- conda_path[1]
      cat("Found conda environment via conda command:", python_path, "\n")
    }
  }
}

if (is.null(python_path)) {
  stop("Could not find Python for docling environment. ",
       "Please run 'bash scripts/setup_docling_env.sh' to set up the environment.\n",
       "Searched locations:\n",
       "  - Venv: ", venv_path, "\n",
       "  - Conda: ", paste(possible_paths, collapse = ", "), "\n")
}

Sys.setenv(RETICULATE_PYTHON = python_path)
reticulate::use_python(python_path, required = TRUE)

# Initialize Python and import modules
tryCatch({
  langchain_docling <- reticulate::import("langchain_docling")
  loader_module <- reticulate::import("langchain_docling.loader")
  DoclingLoader <- langchain_docling$DoclingLoader
  ExportType <- loader_module$ExportType
}, error = function(e) {
  stop("Failed to import Python modules. Error: ", conditionMessage(e), 
       "\nPlease ensure the '", env_name, "' conda environment has langchain-docling installed.")
})

# ============================================================================
# Setup Directories
# ============================================================================
pdf_folder <- "data-raw/abq_mayor_2025_questionnaires"
output_folder <- "data/abq_mayor_2025_questionnaires"

# Create output folder if it doesn't exist
dir.create(output_folder, showWarnings = FALSE, recursive = TRUE)

# ============================================================================
# Get List of PDF Files
# ============================================================================
pdf_files <- list.files(pdf_folder, pattern = "\\.pdf$", full.names = TRUE, ignore.case = TRUE)

if (length(pdf_files) == 0) {
  stop("No PDF files found in ", pdf_folder)
}

cat("Found", length(pdf_files), "PDF file(s) to process\n\n")

# ============================================================================
# Process Each PDF File
# ============================================================================
extracted_files <- character(0)

for (pdf_path in pdf_files) {
  pdf_filename <- basename(pdf_path)
  cat("Processing:", pdf_filename, "\n")
  
  tryCatch({
    # Create loader and extract markdown
    loader <- DoclingLoader(
      file_path = pdf_path,
      export_type = ExportType$MARKDOWN
    )
    
    docs <- loader$load()
    extracted_text <- docs[[1]]$page_content
    
    # Save to markdown file
    md_filename <- sub("\\.pdf$", ".md", pdf_filename, ignore.case = TRUE)
    md_path <- file.path(output_folder, md_filename)
    
    writeLines(extracted_text, md_path, useBytes = TRUE)
    
    extracted_files <- c(extracted_files, md_path)
    cat("  ✓ Extracted and saved:", md_path, "\n")
    
  }, error = function(e) {
    cat("  ✗ Error processing", pdf_filename, ":", conditionMessage(e), "\n")
  })
  
  cat("\n")
}

# ============================================================================
# Summary
# ============================================================================
if (length(extracted_files) > 0) {
  cat("Successfully extracted", length(extracted_files), "file(s) to", output_folder, "/\n")
  cat("Files created:\n")
  for (file in extracted_files) {
    cat("  -", basename(file), "\n")
  }
} else {
  cat("No files were successfully extracted.\n")
}

