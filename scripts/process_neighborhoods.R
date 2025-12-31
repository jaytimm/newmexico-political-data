# ============================================================================
# Process Neighborhood Associations KMZ to GeoJSON
# ============================================================================
# This script processes the Bernalillo County Neighborhood Associations KMZ
# file and converts it to a cleaned GeoJSON format for use in analysis.
#
# Data source: Neighborhood Associations KMZ file
# ============================================================================

# Install and load required packages
if (!require("pacman", quietly = TRUE)) {
  install.packages("pacman")
}

pacman::p_load(
  sf,          # Spatial data handling
  dplyr        # Data manipulation
)

# ============================================================================
# Load KMZ File
# ============================================================================
kmz_file <- "data-raw/NeighborhoodAssociations.kmz"

# Try reading KMZ directly (some versions of sf support this)
neighborhoods <- tryCatch({
  st_read(kmz_file, quiet = TRUE)
}, error = function(e) {
  # If direct read fails, unzip and read KML
  cat("Direct KMZ read failed, extracting...\n")
  temp_dir <- tempdir()
  unzip(kmz_file, exdir = temp_dir)
  
  # Find the KML file in the extracted contents
  kml_files <- list.files(temp_dir, pattern = "\\.kml$", recursive = TRUE, full.names = TRUE)
  if (length(kml_files) > 0) {
    kml_file <- kml_files[1]
    st_read(kml_file, quiet = TRUE)
  } else {
    stop("Could not find KML file in KMZ archive")
  }
})

cat("Loaded", nrow(neighborhoods), "neighborhood features\n")

# ============================================================================
# Process Neighborhood Names
# ============================================================================
# Find the name column (could be Name, name, NAME, Description, etc.)
name_col <- NULL
for (col in c("Name", "name", "NAME", "Description", "description", "DESCRIPTION")) {
  if (col %in% names(neighborhoods)) {
    name_col <- col
    break
  }
}

if (is.null(name_col)) {
  stop("Could not find name column in neighborhood data")
}

cat("Using column '", name_col, "' for neighborhood names\n")

# Extract neighborhood names
neighborhoods <- neighborhoods %>%
  mutate(
    # Get the raw name
    raw_name = as.character(!!sym(name_col)),
    # Extract short name (before "Neighborhood Association" or similar)
    neighborhood_name = gsub("\\s+Neighborhood\\s+Association.*$", "", raw_name, ignore.case = TRUE),
    neighborhood_name = trimws(neighborhood_name),
    # Full name is the original
    neighborhood_full_name = raw_name,
    # Add county name (all neighborhoods are in Bernalillo County)
    COUNTY_NAM = "Bernalillo"
  )

# ============================================================================
# Calculate Acres
# ============================================================================
# Transform to a projected CRS for area calculation
# Use NAD83 / New Mexico Central (EPSG:26913) for accurate area calculations
target_crs <- st_crs("EPSG:26913")

# Set CRS if missing (KML files are typically WGS84)
if (is.na(st_crs(neighborhoods))) {
  st_crs(neighborhoods) <- st_crs("EPSG:4326")
}

# Transform to projected CRS for area calculation
neighborhoods_projected <- st_transform(neighborhoods, target_crs)

# Calculate area in square meters, then convert to acres
# 1 acre = 4046.8564224 square meters
neighborhoods_projected <- neighborhoods_projected %>%
  mutate(
    area_sq_m = as.numeric(st_area(geometry)),
    acres = round(area_sq_m / 4046.8564224, 1)
  )

# Transform back to WGS84 (EPSG:4326) for GeoJSON output
neighborhoods_final <- st_transform(neighborhoods_projected, st_crs("EPSG:4326"))

# ============================================================================
# Select and Order Columns
# ============================================================================
neighborhoods_final <- neighborhoods_final %>%
  select(COUNTY_NAM, neighborhood_name, neighborhood_full_name, acres, geometry) %>%
  arrange(neighborhood_name)

cat("Processed", nrow(neighborhoods_final), "neighborhoods\n")
cat("Total area:", round(sum(neighborhoods_final$acres), 1), "acres\n")

# ============================================================================
# Save Output
# ============================================================================
dir.create("data/boundaries", showWarnings = FALSE, recursive = TRUE)

output_file <- "data/boundaries/nm_neighborhoods_bernco.geojson"
st_write(neighborhoods_final, output_file, delete_dsn = TRUE, quiet = TRUE)

cat("\nNeighborhood data saved to:", output_file, "\n")
cat("Features:", nrow(neighborhoods_final), "\n")
cat("CRS:", st_crs(neighborhoods_final)$input, "\n")

