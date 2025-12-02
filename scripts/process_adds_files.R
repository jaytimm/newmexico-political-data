# ============================================================================
# Process Adds Files (2000/2002 County-Level Data)
# ============================================================================
# This script processes the adds folder files which contain county-level
# election data for 2000/2002 in a different format than the main files.
# It transforms them to match the bigun structure.
# ============================================================================

library(dplyr)
library(tidyr)
library(data.table)

# ============================================================================
# Function to process a single adds file
# ============================================================================
process_adds_file <- function(file_path) {
  
  # Extract year and office from filename
  # Format: add-{office}-{year}_{id}_table.csv
  filename <- basename(file_path)
  parts <- strsplit(filename, "_")[[1]]
  office_year <- parts[1]  # e.g., "add-us-pres-2000"
  
  # Extract office and year
  office_year_clean <- gsub("^add-", "", office_year)
  office_year_split <- strsplit(office_year_clean, "-")[[1]]
  
  # Year is the last element
  year <- office_year_split[length(office_year_split)]
  
  # Office is everything before the year
  office_parts <- office_year_split[-length(office_year_split)]
  office <- paste(office_parts, collapse = " ")
  
  # Map office abbreviations to full names
  office_map <- list(
    "us pres" = "President of the United States",
    "us senate" = "United States Senator",
    "nm sos" = "Secretary of State"
  )
  
  office_key <- paste(office_parts, collapse = " ")
  if (office_key %in% names(office_map)) {
    office_name <- office_map[[office_key]]
  } else {
    # Capitalize first letter of each word
    office_name <- paste(toupper(substring(office_parts, 1, 1)), 
                        substring(office_parts, 2), 
                        sep = "", collapse = " ")
  }
  
  # Read the file (skip first two header rows, they're metadata)
  # Actually, we need to read all rows to parse headers
  raw_data <- readLines(file_path, warn = FALSE)
  
  # Parse header rows using read.csv to handle CSV properly
  header_df <- read.csv(text = paste(raw_data[1:2], collapse = "\n"), header = FALSE, stringsAsFactors = FALSE)
  
  # Candidate names are in first row (skip first 2 empty columns, exclude last 2 Total columns)
  candidate_names <- header_df[1, 3:(ncol(header_df) - 2)]
  # Party names are in second row (same positions)
  party_names <- header_df[2, 3:(ncol(header_df) - 2)]
  
  # Convert to character vectors
  candidate_names <- as.character(candidate_names)
  party_names <- as.character(party_names)
  
  # Remove empty candidates/parties
  candidate_names <- candidate_names[candidate_names != ""]
  party_names <- party_names[party_names != ""]
  
  # Read data starting from row 3 using read.csv for proper CSV parsing
  data_df <- read.csv(text = paste(raw_data[3:length(raw_data)], collapse = "\n"), 
                      header = FALSE, stringsAsFactors = FALSE, 
                      col.names = c("division_type", "division_name", 
                                   paste0("candidate_", seq_along(candidate_names)),
                                   "total_votes", "total_ballots"))
  
  # Parse each row
  results <- list()
  for (row_idx in 1:nrow(data_df)) {
    division_type <- trimws(data_df$division_type[row_idx])
    division_name <- trimws(data_df$division_name[row_idx])
    
    # Skip if empty
    if (division_type == "" || division_name == "") next
    
    # Get vote counts for each candidate
    vote_counts <- as.numeric(data_df[row_idx, paste0("candidate_", seq_along(candidate_names))])
    
    # Create rows for each candidate
    for (i in seq_along(candidate_names)) {
      if (i <= length(vote_counts) && i <= length(party_names)) {
        candidate <- trimws(candidate_names[i])
        party <- trimws(party_names[i])
        votes <- vote_counts[i]
        
        # Skip if candidate name is empty or votes is NA
        if (candidate == "" || is.na(votes)) next
        
        results[[length(results) + 1]] <- data.frame(
          election_type = "General",
          election_date = year,
          office_name = office_name,
          district_type = ifelse(division_type == "State", "State", "State"),  # All are statewide
          district_name = ifelse(division_type == "State", "New Mexico", "New Mexico"),
          candidate_name = candidate,
          division_type = ifelse(division_type == "State", "State", "County"),
          pc = ifelse(division_type == "State", NA, division_name),  # County name goes in pc
          division_name = ifelse(division_type == "State", "New Mexico", division_name),
          vote_channel = "Total",  # County-level totals, not broken down by channel
          is_winner = NA,  # Will be calculated later
          candidate_party_name = ifelse(party == "", NA, party),
          votes = votes,
          stringsAsFactors = FALSE
        )
      }
    }
  }
  
  # Combine all results
  if (length(results) > 0) {
    return(do.call(rbind, results))
  } else {
    return(NULL)
  }
}

# ============================================================================
# Process all adds files
# ============================================================================
adds_dir <- "data-raw/electionstats.sos.nm.gov/adds"
adds_files <- list.files(adds_dir, pattern = "\\.csv$", full.names = TRUE)

cat("Processing", length(adds_files), "adds files...\n")

adds_data <- list()
for (file in adds_files) {
  cat("Processing:", basename(file), "\n")
  tryCatch({
    result <- process_adds_file(file)
    if (!is.null(result)) {
      adds_data[[length(adds_data) + 1]] <- result
    }
  }, error = function(e) {
    cat("Error processing", basename(file), ":", e$message, "\n")
  })
}

# Combine all adds data
if (length(adds_data) > 0) {
  adds_combined <- do.call(rbind, adds_data)
  cat("\nProcessed", nrow(adds_combined), "rows from adds files\n")
  cat("Years:", paste(sort(unique(adds_combined$election_date)), collapse = ", "), "\n")
  cat("Offices:", paste(sort(unique(adds_combined$office_name)), collapse = ", "), "\n")
  
  # Save for inspection
  write.csv(adds_combined, "data-raw/electionstats.sos.nm.gov/adds_processed.csv", row.names = FALSE)
  cat("\nSaved processed adds data to: data-raw/electionstats.sos.nm.gov/adds_processed.csv\n")
  
  # Assign to global environment for use when sourced
  assign("adds_combined", adds_combined, envir = .GlobalEnv)
} else {
  cat("\nNo data processed from adds files.\n")
  assign("adds_combined", NULL, envir = .GlobalEnv)
}

