# ============================================================================
# Generate Data Composition Table
# ============================================================================
# This script analyzes the election results data and creates a CSV file
# showing which offices have data for each election year.
# ============================================================================

library(dplyr)
library(readr)

# Read the election results
df <- read.csv("data/elections/nm_election_results_2000-24.csv", 
               stringsAsFactors = FALSE)

# Get unique years and offices
# Include all years from 2000-2024, even if no data exists
years_in_data <- sort(unique(df$election_date))
all_years <- seq(2000, 2024, by = 2)  # Even years only (general elections)
years <- all_years
offices <- sort(unique(df$office_name))

# Create composition table
composition <- data.frame(Office = offices, stringsAsFactors = FALSE)

# Add a column for each year
for (year in years) {
  year_col <- character(length(offices))
  
  for (i in seq_along(offices)) {
    office <- offices[i]
    
    # Check if this year exists in the data at all
    if (year %in% years_in_data) {
      year_data <- df[df$election_date == year & df$office_name == office, ]
      
      if (nrow(year_data) > 0) {
        # For district-based offices, count unique districts
        if (office %in% c("United States Representative", "State Senate", "State Representative")) {
          unique_districts <- length(unique(year_data$district_name))
          year_col[i] <- paste0("X (", unique_districts, ")")
        } else {
          year_col[i] <- "X"
        }
      } else {
        year_col[i] <- ""
      }
    } else {
      # Year doesn't exist in data at all - leave empty
      year_col[i] <- ""
    }
  }
  
  # Store with year as column name (will be preserved with check.names = FALSE when reading)
  composition[[as.character(year)]] <- year_col
}

# Save as CSV
write.csv(composition, "data/data_composition.csv", row.names = FALSE)

cat("Data composition table saved to data/data_composition.csv\n")
cat("Years included:", paste(years, collapse = ", "), "\n")

