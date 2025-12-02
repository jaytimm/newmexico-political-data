# ============================================================================
# Process New Mexico Election Data
# ============================================================================
# This script processes raw election data from the New Mexico Secretary of
# State and creates cleaned datasets for analysis.
#
# Data source: https://electionstats.sos.nm.gov/
# ============================================================================

# Install and load required packages
if (!require("pacman", quietly = TRUE)) {
  install.packages("pacman")
}

pacman::p_load(
  sf,          # Spatial data handling
  dplyr,       # Data manipulation
  data.table,  # Fast data operations
  tidyr,       # Data reshaping
  janitor      # Data cleaning utilities
)

# ============================================================================
# Load Precinct Boundaries
# ============================================================================
# Load the official Voting Tabulation District (VTD) boundaries from the
# 2020 redistricting cycle.

nm_vtd_map <- sf::st_read("data-raw/gstore.rgis/NM_VTD_20211002.geojson")

# ============================================================================
# Load and Process Election Results
# ============================================================================
# Process raw election data files from the New Mexico Secretary of State.
# The files have a hierarchical structure that requires flattening: county
# names appear in separate rows from precinct results, and vote channels
# (early voting, election day, etc.) are broken out separately.

# Read all raw CSV files (excluding adds folder - processed separately)
fs <- list.files("data-raw/electionstats.sos.nm.gov/", 
                 pattern = "^elstats_search", 
                 full.names = TRUE)
bigun99 <- lapply(fs, read.csv) |> data.table::rbindlist()

# ============================================================================
# Load and clean raw election data
# ============================================================================
bigun <- bigun99 |> 
  filter(election_type == 'General') |>
  filter(!grepl('Court', office_name)) |>
  filter(district_type %in% c('Congressional District',
                              'State Representative District',
                              'State Senate District',
                              'State',
                              ##
                              'Governor and Lieutenant Governor District')) |>
  
  mutate(pc = ifelse(grepl('[0-9]', division_name), 
                     NA, division_name)) |>
  mutate(election_date = ifelse(is.character(election_date) & nchar(election_date) == 4,
                                election_date,  # Already a year string (from adds)
                                format(as.Date(election_date), "%Y"))) |>  # Convert date to year
  
  ## corrections
  mutate(vote_channel = ifelse(is.na(vote_channel), 'Election Day 2000', vote_channel)) |>
  mutate(division_name = sub(' - .*$', '', division_name)) |>
  
  ### 2010 weirdness.
  mutate(office_name = gsub('Governor and Lieutenant Governor', 'Governor', office_name),
         district_name = gsub('Governor and Lieutenant Governor', 'New Mexico', district_name),
         district_type = gsub('Governor and Lieutenant Governor', 'State', district_type)) |>
  
  tidyr::fill(pc, .direction = 'down') |>
  select(election_type, election_date, office_name, district_type, district_name,
         candidate_name, division_type, pc, division_name,
         vote_channel, is_winner, candidate_party_name, votes)

# Process and combine adds files (2000/2002 county-level data in different format)
# Add after bigun is created so structure matches (after column selection)
source("scripts/process_adds_files.R")
if (exists("adds_combined") && !is.null(adds_combined) && nrow(adds_combined) > 0) {
  # Convert adds_combined to match bigun structure (already has correct columns)
  adds_df <- as.data.frame(adds_combined)
  # Combine with bigun
  bigun <- rbind(bigun, adds_df)
  cat("Combined", nrow(adds_combined), "rows from adds files with bigun\n")
}

# Note: The placement of voter privacy rows relative to county names can
# break the fill-down process in creation of 'pc' column. This affects
# two precincts in two races, but does not impact totals or win calculations.
# This is an underlying data issue that could be addressed here if needed.
# prob_precincts <- bigun |> filter(pc == 'Voter Privacy', division_name != 'Voter Privacy') |>
#   distinct(election_date, office_name, district_type, district_name)

# ============================================================================
# Filter to precinct and state level, exclude Voter Privacy
# ============================================================================
df <- bigun |>
  filter(division_type %in% c("Precinct", "County")) |>
  filter(vote_channel != "Voter Privacy") |>
  filter(!pc %in% c('Fed', 'Voter Privacy')) |>
  mutate(votes = as.numeric(votes))

# ============================================================================
# TABLE 1: FINAL RESULTS (Statewide)
# ============================================================================
# Calculate statewide vote totals, winners, and vote percentages for
# every race.

final_results <- df |>
  filter(division_type == "County") |>
  filter(!candidate_name %in% c("Total Ballots Cast", "Total Votes Cast")) |>
  group_by(election_date, office_name, district_name, candidate_name, 
           candidate_party_name) |>
  summarise(votes = sum(votes, na.rm = TRUE), .groups = "drop") |>
  group_by(election_date, office_name, district_name) |>
  mutate(
    is_winner = votes == max(votes),
    pct = round(votes / sum(votes) * 100, 1)
  ) |>
  ungroup() |>
  arrange(election_date, office_name, district_name, desc(votes))

# ============================================================================
# TABLE 2: PRECINCT-LEVEL D/R/OTHER
# ============================================================================
# Create precinct-level vote totals broken down by party (Democratic,
# Republican, and other).

# Map parties to D/R/Other
precinct_data <- df |>
  filter(division_type == "Precinct") |>
  filter(candidate_name != "Total Votes Cast") |>
  mutate(party_collapsed = case_when(
    candidate_party_name == "Democratic" ~ "dem",
    candidate_party_name == "Republican" ~ "rep",
    TRUE ~ "other"
  ))

# Sum votes by precinct/race/party (collapsing vote channels)
precinct_aggregated <- precinct_data |>
  group_by(election_date, office_name, district_type, district_name,
           pc, division_name, party_collapsed) |>
  summarise(votes = sum(votes, na.rm = TRUE), .groups = "drop")

# Pivot to wide format (dem, rep, other columns)
precinct_wide <- precinct_aggregated |>
  tidyr::pivot_wider(
    names_from = party_collapsed,
    values_from = votes,
    values_fill = 0
  )

# Calculate votes_cast from actual "Total Votes Cast" rows
total_votes <- df |>
  filter(division_type == "Precinct") |>
  filter(candidate_name == "Total Votes Cast") |>
  group_by(election_date, office_name, district_type, district_name, 
           pc, division_name) |>
  summarise(votes_cast = sum(votes, na.rm = TRUE), .groups = "drop")

# Join total votes and calculate other
precinct_level <- precinct_wide |>
  left_join(total_votes, by = c("election_date", 
                                "office_name", 
                                "district_type", 
                                "district_name", 
                                "pc", 
                                "division_name")) |>
  mutate(other = votes_cast - (dem + rep)) |>
  select(election_date, office_name, district_type, district_name, 
         pc, division_name, dem, rep, other, votes_cast) |>
  arrange(election_date, office_name, pc, division_name) |>
  rename(COUNTY_NAM = pc, VTD_NUM = division_name)

# ============================================================================
# Create Precinct-District Crosswalk
# ============================================================================
# Extract district assignments from 2024 election data and create a
# crosswalk mapping each precinct to its congressional, state house,
# and state senate districts.

precinct_districts <- precinct_level |>
  filter(district_type != 'State', election_date == '2024') |>
  select(COUNTY_NAM, VTD_NUM, district_name, office_name, district_type) |>
  distinct() |>
  select(-office_name) |>
  tidyr::pivot_wider(
    names_from = district_type,
    values_from = district_name,
    values_fn = first
  ) |>
  janitor::clean_names() |>
  rename(COUNTY_NAM = county_nam, VTD_NUM = vtd_num)

# ============================================================================
# Join District Crosswalk to VTD Map
# ============================================================================
# Add district assignments to the precinct boundary map.

nm_vtd_with_districts <- nm_vtd_map |>
  mutate(VTD_NUM = as.character(VTD_NUM)) |>
  left_join(precinct_districts, by = c("COUNTY_NAM", "VTD_NUM"))

# ============================================================================
# Save Outputs
# ============================================================================
dir.create("data/boundaries", showWarnings = FALSE, recursive = TRUE)
dir.create("data/elections", showWarnings = FALSE, recursive = TRUE)

sf::st_write(nm_vtd_with_districts, 
             "data/boundaries/nm_vtd_with_districts_2021.geojson", 
             delete_dsn = TRUE)
write.csv(precinct_level, 
          "data/elections/nm_precinct_results_2000-24.csv", 
          row.names = FALSE)
write.csv(final_results, 
          "data/elections/nm_election_results_2000-24.csv", 
          row.names = FALSE)

