# New Mexico Political Data

A collection of New Mexico election results and political geography data
from 2000-2024. This project collates election data from the New Mexico
Secretary of State and combines it with precinct boundary maps that
include district assignments.

**Data sources:** - **Election results:** [New Mexico Secretary of State
Election Statistics](https://electionstats.sos.nm.gov/) - **Precinct
boundaries:** Resource Geographic Information System (RGIS) at
University of New Mexico, based on New Mexico Secretary of State 2020
redistricting data

## What’s Included

This dataset contains:

-   **Precinct boundaries** with district crosswalks (congressional,
    state house, state senate)
-   **Precinct-level election results** with vote totals by party
    (Democratic, Republican, other)
-   **Statewide election results** with winners and vote percentages

All data covers general elections from 2000 through 2024.

## Data Composition

The table below shows which offices have data available for each
election year. For district-based offices (U.S. Representative, State
Senate, State Representative), the number in parentheses indicates how
many districts are included.

| Office | 2000 | 2002 | 2004 | 2006 | 2008 | 2010 | 2012 | 2014 | 2016 | 2018 | 2020 | 2022 | 2024 |
|:--------------|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|
| Attorney General |  | X |  | X |  | X |  | X |  | X |  | X |  |
| Commissioner of Public Lands |  |  |  | X |  | X |  | X |  | X |  | X |  |
| Governor |  | X |  | X |  |  |  | X |  | X |  | X |  |
| President of the United States | X |  | X |  | X |  | X |  | X |  | X |  | X |
| Secretary of State |  | X |  | X |  | X |  | X | X | X |  | X |  |
| State Auditor |  | X |  | X |  | X |  | X |  | X |  | X |  |
| State Representative | X (70) | X (70) | X (70) | X (69) | X (70) | X (70) | X (70) | X (70) | X (70) | X (70) | X (70) | X (70) | X (70) |
| State Senate | X (42) |  | X (42) |  | X (42) |  | X (42) |  | X (42) |  | X (42) |  | X (42) |
| State Treasurer |  | X |  | X |  | X |  | X |  | X |  | X |  |
| United States Representative | X (3) | X (3) | X (3) | X (3) | X (3) | X (3) | X (3) | X (3) | X (3) | X (3) | X (3) | X (3) | X (3) |
| United States Senator | X | X |  | X | X |  | X | X |  | X | X |  | X |

## Data Files

### Precinct Boundaries

-   **File:** `data/boundaries/nm_vtd_with_districts_2021.geojson`
-   **Description:** Voting Tabulation District (VTD) boundaries from
    the 2020 redistricting cycle, obtained from Resource Geographic
    Information System (RGIS) at University of New Mexico. Includes
    precinct geometries and district assignments (congressional, state
    house, state senate). The district assignments were added to the map
    via spatial join using election result data from the Secretary of
    State.

### Election Results

-   **File:** `data/elections/nm_precinct_results_2000-24.csv`

-   **Description:** Precinct-by-precinct vote totals broken down by
    party (Democratic, Republican, other) for all races from 2000-2024.

-   **File:** `data/elections/nm_election_results_2000-24.csv`

-   **Description:** Statewide election results with winners, vote
    totals, and vote percentages for all races from 2000-2024.

## Data Processing

The raw election data was processed to:

-   Aggregate votes across different vote channels (early voting,
    election day, absentee)
-   Exclude judicial races and voter privacy suppressions
-   Create both statewide totals and precinct-level breakdowns by party
-   Add district crosswalks to the precinct boundary map (extracted from
    2024 election data)

The processing script is available in `scripts/process_election_data.R`.

## Notes

-   Only general election results are included
-   Judicial races are excluded
-   Precinct boundaries are from the 2020 redistricting cycle
-   District assignments in the boundary file are derived from election
    result data
-   **Important:** While precinct-level election data goes back to 2004,
    the precinct boundary map is only valid for precinct results from
    2022 onward (when the 2020 redistricting boundaries took effect).
    Earlier election results use different precinct boundaries that do
    not match this map.
-   **Adds Files:** Some 2000 and 2002 election results are not included
    in the larger online database queries from the Secretary of State
    website and must be individually downloaded. These files are stored
    in the `adds` folder and contain election results in a different
    format than the main data files. They were converted to match the
    standard structure and combined with the main dataset.

## Quick Start

Load the data files in R:

``` r
# Load precinct boundaries with district assignments
nm_vtd <- sf::st_read("data/boundaries/nm_vtd_with_districts_2021.geojson")

# Load precinct-level election results
precinct_results <- read.csv("data/elections/nm_precinct_results_2000-24.csv")

# Load statewide election results
statewide_results <- read.csv("data/elections/nm_election_results_2000-24.csv")
```
