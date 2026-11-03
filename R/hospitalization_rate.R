#' Hospitalization rate for a target probability of hospitalization
#'
#' The measles models take a daily hospitalization rate: each day with rash,
#' an agent is hospitalized with probability `h`; otherwise, it recovers when
#' its rash period `D` ends. The probability of hospitalization is then
#' `1 - E[(1 - h)^D]`. This function finds the `h` that gives a target
#' probability, for the rash period the models draw (lognormal, rounded to
#' whole days with a minimum of one; see the Stage Durations section of
#' [ModelMeaslesMixing()]).
#'
#' @param p_hosp Double. Target probability that a case is hospitalized,
#' between 0 and 1.
#' @param rash_period Double. Mean rash period in days (default: 3).
#' @param rash_period_sd Double. Standard deviation of the rash period in days
#' (default: 1). With 0, the rash period is fixed and the rate is
#' `1 - (1 - p_hosp)^(1 / rash_period)`.
#' @returns The daily hospitalization rate, to pass as `hospitalization_rate`
#' to the measles models.
#' @examples
#' # About 10% of cases hospitalized with the default rash period
#' hospitalization_rate(0.1)
#'
#' # A fixed 3-day rash
#' hospitalization_rate(0.1, rash_period_sd = 0)
#' @export
#' @family measles models
hospitalization_rate <- function(
  p_hosp,
  rash_period    = 3,
  rash_period_sd = 1
) {

  stopifnot_double(p_hosp, lb = 0, ub = 1)
  stopifnot_double(rash_period, lb = 0)
  stopifnot_double(rash_period_sd, lb = 0)

  if (p_hosp %in% c(0, 1))
    return(p_hosp)

  pmf <- stage_pmf(rash_period, rash_period_sd)
  days <- seq_along(pmf)

  # The rash periods past the last day of the pmf would add at most
  # (1 - sum(pmf)) * (1 - h)^length(pmf), which is negligible
  p_of <- function(h) 1 - sum(pmf * (1 - h)^days)

  stats::uniroot(
    function(h) p_of(h) - p_hosp,
    interval = c(0, 1),
    tol      = 1e-12
  )$root

}

# Probability that a stage lasts 1, 2, ..., dmax days, as the models draw it:
# a lognormal with this mean and standard deviation, rounded to whole days
# with a minimum of one (inst/include/measles/stages.hpp)
stage_pmf <- function(mean, sd, dmax = 1000) {
  if (sd <= 0 || mean <= 0)
    return(as.numeric(seq_len(dmax) == max(1, round(mean))))
  s2 <- log(1 + sd^2 / mean^2)
  diff(c(0, stats::plnorm(seq_len(dmax) + 0.5, log(mean) - s2 / 2, sqrt(s2))))
}
