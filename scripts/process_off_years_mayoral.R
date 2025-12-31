# ============================================================================
# Process Off-Year Mayoral Election Data
# ============================================================================
# This script processes raw mayoral election data from XLSX files in the
# off-years folder. Mayoral races are non-partisan, so candidates are
# preserved as wide columns rather than being collapsed to dem/rep/other.
#
# Data source: New Mexico Secretary of State off-year election results
# ============================================================================

# Ensure we're in the project root directory
# This script should be run from the project root (where data-raw/ exists)
if (!dir.exists("data-raw")) {
  # Try to find project root
  current_dir <- getwd()
  if (dir.exists(file.path(current_dir, "data-raw"))) {
    # Already in project root
  } else if (dir.exists(file.path(current_dir, "..", "data-raw"))) {
    setwd("..")
  } else {
    cat("Warning: Could not find 'data-raw' directory.\n")
    cat("Current working directory:", getwd(), "\n")
    cat("Please run this script from the project root directory.\n")
  }
}

# Install and load required packages
if (!require("pacman", quietly = TRUE)) {
  install.packages("pacman")
}

pacman::p_load(
  dplyr,       # Data manipulation
  readxl,      # Read Excel files
  tidyr,       # Data reshaping
  janitor,     # Data cleaning utilities
  stringr      # String manipulation
)

# ============================================================================
# City to County mapping for New Mexico
# ============================================================================
city_to_county <- list(
  "Albuquerque" = "Bernalillo",
  "Alamo City" = "Otero",
  "Roswell" = "Chaves"
)

# ============================================================================
# Helper function to process a single XLSX file
# ============================================================================
process_mayoral_file <- function(file_path) {
  cat("Processing:", basename(file_path), "\n")
  
  # Extract election date from filename
  # Format: city_mayoral_YYYY_MUX Results Precinct.xlsx
  filename <- basename(file_path)
  
  # Extract year (should be in format like "2025")
  year_match <- regmatches(filename, regexpr("\\d{4}", filename))
  election_date <- ifelse(length(year_match) > 0, year_match[1], NA)
  
  # Read the Excel file (no header, read all as text initially)
  # Suppress the "New names" warning from readxl
  raw_data <- suppressWarnings(read_excel(file_path, sheet = 1, col_names = FALSE))
  
  # Find the header row (row 6, 0-indexed = row 7 in R)
  # Header row contains: office name, "Precinct", candidate names
  header_row <- 6  # 0-indexed row 6 = R row 7
  
  if (nrow(raw_data) < header_row + 1) {
    cat("  Warning: File too short, skipping\n")
    return(NULL)
  }
  
  # Extract office name (first column of header row)
  # Examples: "MAYOR CITY OF ALBUQUERQUE", "Mayor ALAMO CITY DISTRICT- ALL", "Mayor CITY OF ROSWELL"
  office_name_raw <- as.character(raw_data[header_row + 1, 1])[[1]]
  
  # Clean and standardize office name
  office_name <- office_name_raw |>
    str_trim() |>
    str_replace_all("(?i)MAYOR\\s+", "Mayor ") |>
    str_replace_all("\\s+", " ")
  
  # Extract city name from office name
  # Patterns: "Mayor CITY OF [CITY]", "Mayor [CITY] DISTRICT", etc.
  city_name <- NA
  
  # Try "CITY OF [CITY]" pattern first
  if (grepl("(?i)CITY OF\\s+([A-Z\\s-]+)", office_name, perl = TRUE)) {
    city_match <- regmatches(office_name, regexpr("(?i)CITY OF\\s+([A-Z\\s-]+)", office_name, perl = TRUE))
    city_name <- str_trim(gsub("(?i)^.*CITY OF\\s+", "", city_match, perl = TRUE))
    # Remove "DISTRICT" suffix if present
    city_name <- str_replace_all(city_name, "\\s+DISTRICT.*$", "")
  } else if (grepl("(?i)^Mayor\\s+([A-Z\\s-]+)", office_name, perl = TRUE)) {
    # Try "Mayor [CITY]" pattern (for cases like "Mayor ALAMO CITY DISTRICT")
    city_match <- regmatches(office_name, regexpr("(?i)^Mayor\\s+([A-Z\\s-]+)", office_name, perl = TRUE))
    city_name <- str_trim(gsub("(?i)^Mayor\\s+", "", city_match, perl = TRUE))
    # Remove "DISTRICT" suffix if present
    city_name <- str_replace_all(city_name, "\\s+DISTRICT.*$", "")
  }
  
  # Clean city name
  if (!is.na(city_name)) {
    city_name <- city_name |>
      str_trim() |>
      str_to_title()
  }
  
  # Extract candidate names (columns 3 onwards from header row)
  header_values <- as.character(raw_data[header_row + 1, ])
  candidate_cols <- which(!is.na(header_values) & header_values != "" & 
                          header_values != "Precinct" & 
                          !grepl("(?i)^(MAYOR|Mayor)", header_values, perl = TRUE))
  candidate_names <- header_values[candidate_cols]
  
  # Clean candidate names (remove extra whitespace, convert to valid column names)
  candidate_names_clean <- candidate_names |>
    str_trim() |>
    str_replace_all("\\s+", " ") |>
    make_clean_names(case = "title")
  
  # Extract county name from sheet name
  sheet_names <- excel_sheets(file_path)
  county_from_sheet <- ifelse(length(sheet_names) > 0, sheet_names[1], NA)
  
  # Verify/assign county using city-to-county mapping
  county_name <- county_from_sheet
  if (!is.na(city_name) && city_name %in% names(city_to_county)) {
    expected_county <- city_to_county[[city_name]]
    if (!is.na(county_from_sheet) && county_from_sheet != expected_county) {
      cat("  Warning: County mismatch. Sheet says", county_from_sheet, 
          "but city", city_name, "should be in", expected_county, "\n")
    }
    county_name <- expected_county
  }
  
  cat("  Office:", office_name, "\n")
  cat("  City:", city_name, "\n")
  cat("  County:", county_name, "\n")
  cat("  Year:", election_date, "\n")
  cat("  Candidates:", paste(candidate_names_clean, collapse = ", "), "\n")
  
  # Extract data rows (starting from row 7, 0-indexed = row 8 in R)
  data_start_row <- header_row + 2
  data_rows <- raw_data[data_start_row:nrow(raw_data), ]
  
  # Find where data ends (look for "TOTALS" row)
  totals_row <- which(grepl("TOTALS?", data_rows[[2]], ignore.case = TRUE))
  if (length(totals_row) > 0) {
    data_rows <- data_rows[1:(totals_row[1] - 1), ]
  }
  
  # Extract precinct numbers (column 2, which is index 2 in R = column B)
  precinct_col <- 2
  precinct_data <- data_rows[[precinct_col]]
  
  # Remove rows where precinct is NA or empty
  valid_rows <- !is.na(precinct_data) & precinct_data != "" & 
                !grepl("TOTALS?", precinct_data, ignore.case = TRUE)
  data_rows <- data_rows[valid_rows, ]
  precinct_data <- precinct_data[valid_rows]
  
  # Clean precinct numbers (remove "PCT " or "PRECINCT " prefix, extract number)
  precinct_clean <- precinct_data |>
    str_replace_all("(?i)(PCT|PRECINCT)\\s*", "") |>
    str_trim()
  
  # Extract vote counts for each candidate
  # Candidate data starts at column 3 (index 3 in R = column C)
  candidate_start_col <- 3
  n_candidates <- length(candidate_names)
  
  # Create a data frame to store results
  result_list <- list()
  
  for (i in seq_along(precinct_clean)) {
    row_data <- data_rows[i, ]
    precinct_num <- precinct_clean[i]
    
    # Extract votes for each candidate
    candidate_votes <- numeric(n_candidates)
    for (j in seq_len(n_candidates)) {
      col_idx <- candidate_start_col + j - 1
      vote_val <- row_data[[col_idx]]
      
      # Convert to numeric, handling "*" and NA
      if (is.na(vote_val) || vote_val == "*" || vote_val == "") {
        candidate_votes[j] <- 0
      } else {
        candidate_votes[j] <- as.numeric(vote_val)
        if (is.na(candidate_votes[j])) {
          candidate_votes[j] <- 0
        }
      }
    }
    
    # Calculate total votes cast
    votes_cast <- sum(candidate_votes, na.rm = TRUE)
    
    # Create row data
    row_result <- data.frame(
      election_date = election_date,
      office_name = office_name,
      district_type = "City",
      district_name = ifelse(!is.na(city_name), city_name, "Unknown"),
      COUNTY_NAM = county_name,
      VTD_NUM = precinct_num,
      votes_cast = votes_cast,
      stringsAsFactors = FALSE
    )
    
    # Add candidate vote columns
    for (j in seq_len(n_candidates)) {
      col_name <- candidate_names_clean[j]
      row_result[[col_name]] <- candidate_votes[j]
    }
    
    result_list[[i]] <- row_result
  }
  
  # Combine all rows
  result_df <- do.call(rbind, result_list)
  
  cat("  Processed", nrow(result_df), "precincts\n")
  
  return(result_df)
}

# ============================================================================
# Process all mayoral XLSX files
# ============================================================================
off_years_dir <- "data-raw/off-years.sos.nm.gov"

# Diagnostic information
cat("Current working directory:", getwd(), "\n")
cat("Checking for directory:", off_years_dir, "\n")
cat("Directory exists:", dir.exists(off_years_dir), "\n")

# Check if directory exists
if (!dir.exists(off_years_dir)) {
  cat("\nERROR: Directory", off_years_dir, "does not exist.\n")
  cat("Current working directory:", getwd(), "\n")
  cat("Full path checked:", file.path(getwd(), off_years_dir), "\n")
  cat("\nPlease ensure you are running this script from the project root directory.\n")
  cat("The project root should contain both 'data-raw' and 'scripts' directories.\n")
  stop("Directory not found. Please run this script from the project root directory.")
}

mayoral_files <- list.files(off_years_dir, 
                           pattern = "mayoral", 
                           full.names = TRUE,
                           ignore.case = TRUE)
# Filter to only .xlsx files
mayoral_files <- mayoral_files[grepl("\\.xlsx$", mayoral_files, ignore.case = TRUE)]

if (length(mayoral_files) == 0) {
  cat("No mayoral XLSX files found in", off_years_dir, "\n")
  cat("Current working directory:", getwd(), "\n")
  cat("Directory exists:", dir.exists(off_years_dir), "\n")
  cat("Files in directory:", paste(list.files(off_years_dir), collapse = ", "), "\n")
} else {
  cat("Found", length(mayoral_files), "mayoral files to process\n\n")
  
  # Process each file
  all_results <- list()
  for (file in mayoral_files) {
    result <- process_mayoral_file(file)
    if (!is.null(result)) {
      all_results[[length(all_results) + 1]] <- result
    }
  }
  
  # Combine all results
  if (length(all_results) > 0) {
    # Get all unique column names across all results
    all_cols <- unique(unlist(lapply(all_results, names)))
    
    # Metadata columns (always present)
    metadata_cols <- c("election_date", "office_name", "district_type", 
                      "district_name", "COUNTY_NAM", "VTD_NUM", "votes_cast")
    
    # Candidate columns (all others)
    candidate_cols <- setdiff(all_cols, metadata_cols)
    candidate_cols <- sort(candidate_cols)
    
    # Ensure all data frames have the same columns (fill missing with 0)
    all_results_aligned <- lapply(all_results, function(df) {
      missing_cols <- setdiff(all_cols, names(df))
      for (col in missing_cols) {
        df[[col]] <- 0
      }
      # Reorder columns
      df <- df[, c(metadata_cols, candidate_cols), drop = FALSE]
      return(df)
    })
    
    # Combine all results
    mayoral_precinct_data <- do.call(rbind, all_results_aligned)
    
    # Final ordering
    mayoral_precinct_data <- mayoral_precinct_data |>
      arrange(election_date, office_name, district_name, COUNTY_NAM, VTD_NUM)
    
    cat("\n========================================\n")
    cat("Summary:\n")
    cat("Total precincts:", nrow(mayoral_precinct_data), "\n")
    cat("Elections:", paste(sort(unique(mayoral_precinct_data$election_date)), collapse = ", "), "\n")
    cat("Offices:", paste(sort(unique(mayoral_precinct_data$office_name)), collapse = ", "), "\n")
    cat("Cities:", paste(sort(unique(mayoral_precinct_data$district_name)), collapse = ", "), "\n")
    cat("========================================\n")
    
    # Save output
    output_file <- "data/elections/nm_mayoral_precinct_results.csv"
    write.csv(mayoral_precinct_data, output_file, row.names = FALSE)
    cat("\nSaved mayoral precinct data to:", output_file, "\n")
    
  } else {
    cat("\nNo data was successfully processed.\n")
  }
}

