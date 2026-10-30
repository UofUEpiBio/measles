# Derivation of the stage-duration and hospitalization defaults in
# inst/extdata/measles_parameters.csv:
#
# 1. incubation_period_sd: from the lognormal fit of Lessler et al. (2009).
# 2. prodromal_period_sd: fitted to the 1861 Hagelloch outbreak.
# 3. rash_period_sd: an assumption; this only reports what it implies.
# 4. hospitalization_rate: the daily rate that gives 10% of cases
#    hospitalized under the default rash period.
#
# The models draw a stage's duration as a lognormal with the given mean and
# standard deviation (natural scale), rounded to whole days with a minimum of
# one (inst/include/measles/stages.hpp); stage_pmf() reproduces that.
#
# The Hagelloch data are read from the `surveillance` package (GPL-2), not
# copied into this repository. Only aggregate results are written, to
# data-raw/stage_durations.csv.
#
# Usage (from the package root): Rscript data-raw/stage_durations.R
# Date: 2026-10-30

# Probability that a stage lasts 1, 2, ..., dmax days
stage_pmf <- function(mean, sd, dmax = 200) {
  if (sd <= 0)
    return(as.numeric(seq_len(dmax) == max(1, round(mean))))
  s2 <- log(1 + sd^2 / mean^2)
  diff(c(0, plnorm(seq_len(dmax) + 0.5, log(mean) - s2 / 2, sqrt(s2))))
}

results <- list()
add <- function(parameter, quantity, value, note = "") {
  results[[length(results) + 1L]] <<- data.frame(
    parameter = parameter,
    quantity  = quantity,
    value     = value,
    note      = note
  )
}

# 1. Incubation period ---------------------------------------------------------
# Lessler et al. (2009), Lancet Infect Dis 9(5):291-300, Table 3: measles
# incubation period (exposure to first symptoms), lognormal with median 12.5
# days and dispersion (geometric sd) 1.23. The coefficient of variation of a
# lognormal depends only on its sdlog, so it carries over to the model's mean.
sdlog_lessler <- log(1.23)
cv_incubation <- sqrt(exp(sdlog_lessler^2) - 1)
mean_incubation <- 12 # Package default (Utah DHHS Measles Disease Plan)
sd_incubation <- cv_incubation * mean_incubation

add("incubation_period_sd", "Coefficient of variation (Lessler et al. 2009)", cv_incubation)
add("incubation_period_sd", "sd at the default mean of 12 days", sd_incubation, "Default: 2.5")

pmf <- stage_pmf(mean_incubation, 2.5)
add("incubation_period_sd", "P(latent > 21 days), lognormal", sum(pmf[-(1:21)]))
add(
  "incubation_period_sd",
  "P(latent > 21 days), geometric (before 0.4.1-0)",
  (1 - 1 / mean_incubation)^21
)

# 2. Prodromal period ----------------------------------------------------------
# Days from prodrome onset (PRO) to rash onset (ERU) in the 1861 measles
# outbreak in Hagelloch, Germany (Pfeilsticker 1863; Oesterle 1992), as
# distributed in surveillance::hagelloch.df (Meyer et al. 2017, J Stat Softw
# 77(11)). Durations are recorded in whole days, so each is treated as
# interval censored: a count of k days is a duration in (k - 0.5, k + 0.5].
# Zero-day intervals (2 of 188) are left out of the fits, as the model's
# minimum is one day.
data("hagelloch", package = "surveillance")
prodromal <- as.numeric(hagelloch.df$ERU - hagelloch.df$PRO)
prodromal <- prodromal[!is.na(prodromal)]

add("prodromal_period_sd", "Cases (n)", length(prodromal))
add("prodromal_period_sd", "Mean (days)", mean(prodromal))
add("prodromal_period_sd", "sd (days)", stats::sd(prodromal))

days <- prodromal[prodromal > 0]
neg_loglik <- function(cdf) {
  function(par) -sum(log(pmax(cdf(days + 0.5, par) - cdf(days - 0.5, par), 1e-300)))
}

fits <- list(
  lognormal = stats::optim(
    c(log(mean(days)), 0.3),
    neg_loglik(function(q, p) plnorm(q, p[1], abs(p[2])))
  ),
  gamma = stats::optim(
    c(4, 1),
    neg_loglik(function(q, p) pgamma(q, shape = abs(p[1]), scale = abs(p[2])))
  ),
  weibull = stats::optim(
    c(3, 4),
    neg_loglik(function(q, p) pweibull(q, shape = abs(p[1]), scale = abs(p[2])))
  )
)
fit_exp <- stats::optimize(
  function(rate) neg_loglik(function(q, p) pexp(q, p))(rate),
  c(1e-3, 5)
)

p <- fits$lognormal$par
mean_ln <- exp(p[1] + p[2]^2 / 2)
add("prodromal_period_sd", "Lognormal fit: mean (days)", mean_ln)
add("prodromal_period_sd", "Lognormal fit: sd (days)", mean_ln * sqrt(exp(p[2]^2) - 1), "Default: 1.7")
add("prodromal_period_sd", "Lognormal fit: AIC", 2 * fits$lognormal$value + 4)

p <- abs(fits$gamma$par)
add("prodromal_period_sd", "Gamma fit: mean (days)", p[1] * p[2])
add("prodromal_period_sd", "Gamma fit: sd (days)", sqrt(p[1]) * p[2])
add("prodromal_period_sd", "Gamma fit: AIC", 2 * fits$gamma$value + 4)

p <- abs(fits$weibull$par)
add("prodromal_period_sd", "Weibull fit: mean (days)", p[2] * gamma(1 + 1 / p[1]))
add("prodromal_period_sd", "Weibull fit: AIC", 2 * fits$weibull$value + 4)

add("prodromal_period_sd", "Exponential (geometric) fit: mean (days)", 1 / fit_exp$minimum)
add("prodromal_period_sd", "Exponential (geometric) fit: AIC", 2 * fit_exp$objective + 2)

# 3. Rash period ---------------------------------------------------------------
# The sd of 1 day is an assumption: the model tracks only the infectious part
# of the rash, which ends about 4 days after rash onset (Utah DHHS Measles
# Disease Plan).
pmf <- stage_pmf(3, 1)
add("rash_period_sd", "P(1 to 6 days), mean 3 and sd 1", sum(pmf[1:6]))

# 4. Hospitalization rate ------------------------------------------------------
# Each day with rash, an agent is hospitalized with probability h; otherwise,
# it recovers when its rash period D ends. So P(hospitalized) = 1 - E[(1 - h)^D].
# Target: 10% of cases, as in CDC national data for 2026 (479 of 4,588
# confirmed cases as of October 22, 2026) and close to the 8% in Utah (Jones
# et al. 2026, NEJM Evid 5(8)).
pmf_rash <- stage_pmf(3, 1)
p_hosp <- function(h) 1 - sum(pmf_rash * (1 - h)^seq_along(pmf_rash))

h_exact <- stats::uniroot(function(h) p_hosp(h) - 0.10, c(0, 1), tol = 1e-12)$root
add("hospitalization_rate", "Rate giving 10% hospitalized (exact)", h_exact)
add("hospitalization_rate", "Rate from 1 - (1 - p)^(1/3) (fixed rash)", 1 - 0.9^(1 / 3))
add("hospitalization_rate", "P(hospitalized) at 0.035", p_hosp(0.035), "Default: 0.035")
add("hospitalization_rate", "P(hospitalized) at 0.2 (previous default)", p_hosp(0.2))
add(
  "hospitalization_rate",
  "P(hospitalized) at 0.2 with a geometric rash (before 0.4.1-0)",
  0.2 / (0.2 + 1 / 3)
)

# Writing the results ----------------------------------------------------------
results <- do.call(rbind, results)
results$value <- signif(results$value, 4)
utils::write.csv(results, "data-raw/stage_durations.csv", row.names = FALSE)
print(results, right = FALSE)
