# New Mexico Political Data

## Overview

This project integrates New Mexico political geography and election data
into a unified analytical dataset.

The combined dataset includes:

-   **Precinct Boundaries**: Voting Tabulation Districts (VTDs) from the
    New Mexico Secretary of State’s 2020 redistricting cycle
-   **Election Results**: Precinct-level returns and statewide totals
    from general elections (2000-2024)
-   **District Crosswalks**: Mappings between precincts and their
    congressional, state house, and state senate districts

Election results cover:

-   **Congressional races** (U.S. House)
-   **State legislative races** (State House and State Senate)
-   **Statewide offices** (Governor, U.S. Senate, presidential electors,
    and other statewide positions)

## § Load Precinct Boundaries

This section loads the official Voting Tabulation District (VTD)
boundaries that define New Mexico’s voting precincts. These boundaries
are from the 2020 redistricting cycle and represent the current precinct
geography used in state elections.

The GeoJSON file is read as an sf (simple features) spatial object,
preserving both the geometric data and precinct identifiers needed for
spatial joins.

**Output**: - `data/boundaries/nm_vtd_map_2021.rds` - Spatial object
(sf) containing precinct boundaries with COUNTY_NAM and VTD_NUM
identifiers

## § Load and Process Federal Election Results

This section processes raw election data files from the New Mexico
Secretary of State. The files have a hierarchical structure that
requires flattening: county names appear in separate rows from precinct
results, and vote channels (early voting, election day, etc.) are broken
out separately.

The code handles several data cleaning challenges: - Fills county names
down to precinct rows - Aggregates votes across different vote channels
(early, election day, absentee) - Excludes judicial races and voter
privacy suppressions - Creates both statewide totals and precinct-level
breakdowns by party

Three key outputs are generated:

1.  **Final Results**: Statewide winner and vote share calculations for
    every race
2.  **Precinct-Level Results**: Democratic, Republican, and other party
    votes by precinct for every race
3.  **Precinct-District Crosswalk**: Maps each precinct to its
    congressional district, state house district, and state senate
    district (extracted from 2024 races)

**Outputs**:

-   `data/boundaries/nm_precinct_districts_2021.rds` - Crosswalk mapping
    each precinct (COUNTY_NAM + VTD_NUM) to its congressional_district,
    state_representative_district, and state_senate_district

-   `data/elections/nm_precinct_level_results_2000-24.rds` -
    Precinct-level Democratic, Republican, and other party vote totals
    for all general elections 2000-2024

-   `data/elections/nm_election_results_2000-24.rds` - Statewide
    election results with winners and vote percentages for all races
    2000-2024

## Quick Start: Loading Processed Data

After running the processing scripts above, load the cleaned data for
analysis:

``` r
# Load precinct boundaries
nm_vtd_map <- readRDS("data/boundaries/nm_vtd_map_2021.rds")

# Load precinct-to-district crosswalk
precinct_districts <- readRDS("data/boundaries/nm_precinct_districts_2021.rds")

# Load precinct-level election results
precinct_results <- readRDS("data/elections/nm_precinct_level_results_2000-24.rds")

# Load statewide results
final_results <- readRDS("data/elections/nm_election_results_2000-24.rds")
```
