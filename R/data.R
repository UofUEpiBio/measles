#' Short Creek Mixing Matrix
#'
#' A matrix containing spatial data for the Short Creek area (Hildale city,
#' Utah, Colorado City town, Arizona, and Centenial Park, Arizona).
#' The matrix provides an estimate of
#' the mixing rates between schools and the rest of the population in the area.
#' **IMPORTANT: THE SCHOOL-RELATED DATA IS FAKE. WE ARE STILL
#' DEVELOPING IT.**
#'
#' @format
#' A row-stochastic matrix (rows add up to one) with 18 rows and 18 columns
#' with the
#'
#' @source
#' The data was generated using the `multigroup.vaccine` R package:
#' Toth D (2025). _multigroup.vaccine: Multigroup Vaccine Model_. R
#' package version 0.1.0, commit 54acee568fbb0666231ab59f19d33841337d7402,
#' <https://github.com/EpiForeSITE/multigroup-vaccine>. The source code
#' is available at <https://github.com/UofUEpiBio/measles>
#'
#'
"short_creek_matrix"

#' Short Creek Population Data by Age Group
#'
#' A dataset containing population information for the Short Creek area
#' (Hildale city, Utah, Colorado City town, Arizona, and Centeial Park,
#' Arizona) organized by age
#' groups. **IMPORTANT: THE SCHOOL-RELATED DATA IS FAKE. WE ARE STILL
#' DEVELOPING IT.**
#'
#' @format A data frame with 18 rows and 4 columns:
#' \describe{
#'   \item{age_labels}{character. Labels describing the age groups.}
#'   \item{agepops}{numeric. Population counts for each age group.}
#'   \item{agelims}{numeric. Age limit boundaries for each group.}
#'   \item{vacc_rate}{numeric. Vaccination rate for each age group.}
#' }
#'
#' @details
#' This dataset provides demographic information for the Short Creek area
#' (Hildale city, Utah, Colorado City town, Arizona, and Centenial Park,
#' Arizona), with population data
#' disaggregated by 18 age categories. This dataset matches the
#' [short_creek_matrix] matrix.
#'
#' @source
#' The data was generated using the `multigroup.vaccine` R package:
#' Toth D (2025). _multigroup.vaccine: Multigroup Vaccine Model_. R
#' package version 0.1.0, commit 54acee568fbb0666231ab59f19d33841337d7402,
#' <https://github.com/EpiForeSITE/multigroup-vaccine>. The source code
#' is available at <https://github.com/UofUEpiBio/measles>
#'
#'
#' @examples
#' data(short_creek)
#' head(short_creek)
#'
"short_creek"
