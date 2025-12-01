---
output: 
  md_document:
    variant: markdown_github
    preserve_yaml: true
---

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

<table style="white-space: nowrap;">
<thead>
<tr>
<th align="left">
Office
</th>
<th align="center">
2000
</th>
<th align="center">
2002
</th>
<th align="center">
2004
</th>
<th align="center">
2006
</th>
<th align="center">
2008
</th>
<th align="center">
2010
</th>
<th align="center">
2012
</th>
<th align="center">
2014
</th>
<th align="center">
2016
</th>
<th align="center">
2018
</th>
<th align="center">
2020
</th>
<th align="center">
2022
</th>
<th align="center">
2024
</th>
</tr>
</thead>
<tbody>
<tr>
<td style="white-space: nowrap;">
Attorney General
</td>
<td align="center" style="white-space: nowrap;">
</td>
<td align="center" style="white-space: nowrap;">
X
</td>
<td align="center" style="white-space: nowrap;">
</td>
<td align="center" style="white-space: nowrap;">
X
</td>
<td align="center" style="white-space: nowrap;">
</td>
<td align="center" style="white-space: nowrap;">
X
</td>
<td align="center" style="white-space: nowrap;">
</td>
<td align="center" style="white-space: nowrap;">
</td>
<td align="center" style="white-space: nowrap;">
</td>
<td align="center" style="white-space: nowrap;">
X
</td>
<td align="center" style="white-space: nowrap;">
</td>
<td align="center" style="white-space: nowrap;">
X
</td>
<td align="center" style="white-space: nowrap;">
</td>
</tr>
<tr>
<td style="white-space: nowrap;">
Commissioner of Public Lands
</td>
<td align="center" style="white-space: nowrap;">
</td>
<td align="center" style="white-space: nowrap;">
</td>
<td align="center" style="white-space: nowrap;">
</td>
<td align="center" style="white-space: nowrap;">
X
</td>
<td align="center" style="white-space: nowrap;">
</td>
<td align="center" style="white-space: nowrap;">
X
</td>
<td align="center" style="white-space: nowrap;">
</td>
<td align="center" style="white-space: nowrap;">
</td>
<td align="center" style="white-space: nowrap;">
</td>
<td align="center" style="white-space: nowrap;">
X
</td>
<td align="center" style="white-space: nowrap;">
</td>
<td align="center" style="white-space: nowrap;">
X
</td>
<td align="center" style="white-space: nowrap;">
</td>
</tr>
<tr>
<td style="white-space: nowrap;">
Governor
</td>
<td align="center" style="white-space: nowrap;">
</td>
<td align="center" style="white-space: nowrap;">
X
</td>
<td align="center" style="white-space: nowrap;">
</td>
<td align="center" style="white-space: nowrap;">
X
</td>
<td align="center" style="white-space: nowrap;">
</td>
<td align="center" style="white-space: nowrap;">
</td>
<td align="center" style="white-space: nowrap;">
</td>
<td align="center" style="white-space: nowrap;">
</td>
<td align="center" style="white-space: nowrap;">
</td>
<td align="center" style="white-space: nowrap;">
X
</td>
<td align="center" style="white-space: nowrap;">
</td>
<td align="center" style="white-space: nowrap;">
X
</td>
<td align="center" style="white-space: nowrap;">
</td>
</tr>
<tr>
<td style="white-space: nowrap;">
President of the United States
</td>
<td align="center" style="white-space: nowrap;">
</td>
<td align="center" style="white-space: nowrap;">
</td>
<td align="center" style="white-space: nowrap;">
X
</td>
<td align="center" style="white-space: nowrap;">
</td>
<td align="center" style="white-space: nowrap;">
X
</td>
<td align="center" style="white-space: nowrap;">
</td>
<td align="center" style="white-space: nowrap;">
X
</td>
<td align="center" style="white-space: nowrap;">
</td>
<td align="center" style="white-space: nowrap;">
X
</td>
<td align="center" style="white-space: nowrap;">
</td>
<td align="center" style="white-space: nowrap;">
X
</td>
<td align="center" style="white-space: nowrap;">
</td>
<td align="center" style="white-space: nowrap;">
X
</td>
</tr>
<tr>
<td style="white-space: nowrap;">
Secretary of State
</td>
<td align="center" style="white-space: nowrap;">
</td>
<td align="center" style="white-space: nowrap;">
</td>
<td align="center" style="white-space: nowrap;">
</td>
<td align="center" style="white-space: nowrap;">
X
</td>
<td align="center" style="white-space: nowrap;">
</td>
<td align="center" style="white-space: nowrap;">
X
</td>
<td align="center" style="white-space: nowrap;">
</td>
<td align="center" style="white-space: nowrap;">
</td>
<td align="center" style="white-space: nowrap;">
X
</td>
<td align="center" style="white-space: nowrap;">
X
</td>
<td align="center" style="white-space: nowrap;">
</td>
<td align="center" style="white-space: nowrap;">
X
</td>
<td align="center" style="white-space: nowrap;">
</td>
</tr>
<tr>
<td style="white-space: nowrap;">
State Auditor
</td>
<td align="center" style="white-space: nowrap;">
</td>
<td align="center" style="white-space: nowrap;">
X
</td>
<td align="center" style="white-space: nowrap;">
</td>
<td align="center" style="white-space: nowrap;">
X
</td>
<td align="center" style="white-space: nowrap;">
</td>
<td align="center" style="white-space: nowrap;">
X
</td>
<td align="center" style="white-space: nowrap;">
</td>
<td align="center" style="white-space: nowrap;">
</td>
<td align="center" style="white-space: nowrap;">
</td>
<td align="center" style="white-space: nowrap;">
X
</td>
<td align="center" style="white-space: nowrap;">
</td>
<td align="center" style="white-space: nowrap;">
X
</td>
<td align="center" style="white-space: nowrap;">
</td>
</tr>
<tr>
<td style="white-space: nowrap;">
State Representative
</td>
<td align="center" style="white-space: nowrap;">
X (70)
</td>
<td align="center" style="white-space: nowrap;">
X (70)
</td>
<td align="center" style="white-space: nowrap;">
X (70)
</td>
<td align="center" style="white-space: nowrap;">
X (69)
</td>
<td align="center" style="white-space: nowrap;">
X (70)
</td>
<td align="center" style="white-space: nowrap;">
X (70)
</td>
<td align="center" style="white-space: nowrap;">
X (70)
</td>
<td align="center" style="white-space: nowrap;">
</td>
<td align="center" style="white-space: nowrap;">
X (70)
</td>
<td align="center" style="white-space: nowrap;">
X (70)
</td>
<td align="center" style="white-space: nowrap;">
X (70)
</td>
<td align="center" style="white-space: nowrap;">
X (70)
</td>
<td align="center" style="white-space: nowrap;">
X (70)
</td>
</tr>
<tr>
<td style="white-space: nowrap;">
State Senate
</td>
<td align="center" style="white-space: nowrap;">
X (42)
</td>
<td align="center" style="white-space: nowrap;">
</td>
<td align="center" style="white-space: nowrap;">
X (42)
</td>
<td align="center" style="white-space: nowrap;">
</td>
<td align="center" style="white-space: nowrap;">
X (42)
</td>
<td align="center" style="white-space: nowrap;">
</td>
<td align="center" style="white-space: nowrap;">
X (42)
</td>
<td align="center" style="white-space: nowrap;">
</td>
<td align="center" style="white-space: nowrap;">
X (42)
</td>
<td align="center" style="white-space: nowrap;">
</td>
<td align="center" style="white-space: nowrap;">
X (42)
</td>
<td align="center" style="white-space: nowrap;">
</td>
<td align="center" style="white-space: nowrap;">
X (42)
</td>
</tr>
<tr>
<td style="white-space: nowrap;">
State Treasurer
</td>
<td align="center" style="white-space: nowrap;">
</td>
<td align="center" style="white-space: nowrap;">
X
</td>
<td align="center" style="white-space: nowrap;">
</td>
<td align="center" style="white-space: nowrap;">
X
</td>
<td align="center" style="white-space: nowrap;">
</td>
<td align="center" style="white-space: nowrap;">
X
</td>
<td align="center" style="white-space: nowrap;">
</td>
<td align="center" style="white-space: nowrap;">
</td>
<td align="center" style="white-space: nowrap;">
</td>
<td align="center" style="white-space: nowrap;">
X
</td>
<td align="center" style="white-space: nowrap;">
</td>
<td align="center" style="white-space: nowrap;">
X
</td>
<td align="center" style="white-space: nowrap;">
</td>
</tr>
<tr>
<td style="white-space: nowrap;">
United States Representative
</td>
<td align="center" style="white-space: nowrap;">
X (3)
</td>
<td align="center" style="white-space: nowrap;">
X (3)
</td>
<td align="center" style="white-space: nowrap;">
X (3)
</td>
<td align="center" style="white-space: nowrap;">
X (3)
</td>
<td align="center" style="white-space: nowrap;">
X (3)
</td>
<td align="center" style="white-space: nowrap;">
X (3)
</td>
<td align="center" style="white-space: nowrap;">
X (3)
</td>
<td align="center" style="white-space: nowrap;">
</td>
<td align="center" style="white-space: nowrap;">
X (3)
</td>
<td align="center" style="white-space: nowrap;">
X (3)
</td>
<td align="center" style="white-space: nowrap;">
X (3)
</td>
<td align="center" style="white-space: nowrap;">
X (3)
</td>
<td align="center" style="white-space: nowrap;">
X (3)
</td>
</tr>
<tr>
<td style="white-space: nowrap;">
United States Senator
</td>
<td align="center" style="white-space: nowrap;">
</td>
<td align="center" style="white-space: nowrap;">
</td>
<td align="center" style="white-space: nowrap;">
</td>
<td align="center" style="white-space: nowrap;">
X
</td>
<td align="center" style="white-space: nowrap;">
X
</td>
<td align="center" style="white-space: nowrap;">
</td>
<td align="center" style="white-space: nowrap;">
X
</td>
<td align="center" style="white-space: nowrap;">
</td>
<td align="center" style="white-space: nowrap;">
</td>
<td align="center" style="white-space: nowrap;">
X
</td>
<td align="center" style="white-space: nowrap;">
X
</td>
<td align="center" style="white-space: nowrap;">
</td>
<td align="center" style="white-space: nowrap;">
X
</td>
</tr>
</tbody>
</table>

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

The raw election data was processed to: - Aggregate votes across
different vote channels (early voting, election day, absentee) - Exclude
judicial races and voter privacy suppressions - Create both statewide
totals and precinct-level breakdowns by party - Add district crosswalks
to the precinct boundary map (extracted from 2024 election data)

The processing script is available in `scripts/process_election_data.R`.

## Notes

-   Only general election results are included
-   Judicial races are excluded
-   Precinct boundaries are from the 2020 redistricting cycle
-   District assignments in the boundary file are derived from election
    result data
-   **Important:** While precinct-level election data goes back to 2000,
    the precinct boundary map is only valid for precinct results from
    2022 onward (when the 2020 redistricting boundaries took effect).
    Earlier election results use different precinct boundaries that do
    not match this map.

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
