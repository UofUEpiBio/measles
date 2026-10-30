# Stage durations: fixed (sd = 0) and lognormal (the default)

# With fixed durations and no transmission, every initial case goes through
# its stages on the same days: latent for 5 days, prodromal for 3, rash for 2
n <- 200
model <- ModelMeaslesMixing(
  n                    = n,
  prevalence           = 1,
  contact_matrix       = matrix(1),
  transmission_rate    = 0,
  prop_vaccinated      = 0,
  isolation_period     = -1,
  incubation_period    = 5,
  prodromal_period     = 3,
  rash_period          = 2,
  hospitalization_rate = 0,
  incubation_period_sd = 0,
  prodromal_period_sd  = 0,
  rash_period_sd       = 0
)

add_entity(model, entity("Population", n, as_proportion = FALSE))
verbose_off(model)
run(model, ndays = 20, seed = 123)

tr <- get_hist_transition_matrix(model)
moves <- function(from, to) {
  x <- tr[tr$state_from == from & tr$state_to == to & tr$counts > 0, ]
  stats::setNames(x$counts, x$date)
}

expect_equal(moves("Latent", "Prodromal"), c("5" = n))
expect_equal(moves("Prodromal", "Rash"), c("8" = n))
expect_equal(moves("Rash", "Recovered"), c("10" = n))

# The standard deviations are model parameters
expect_equal(get_param(model, "Incubation period sd"), 0)
expect_equal(get_param(model, "Rash period sd"), 0)

# With the default lognormal incubation period (mean 12, sd 2.5), about 0.2%
# of cases are latent for more than 21 days (with the geometric period of
# earlier versions, about 16% were)
model_school <- ModelMeaslesSchool(
  n                 = 2000,
  prevalence        = 2000,
  contact_rate      = 1,
  transmission_rate = 0,
  prop_vaccinated   = 0,
  quarantine_period = -1,
  isolation_period  = -1
)

verbose_off(model_school)
run(model_school, ndays = 60, seed = 331)

tr <- get_hist_transition_matrix(model_school)
latent <- tr[tr$state_from == "Latent" & tr$state_to == "Prodromal", ]
expect_equal(sum(latent$counts), 2000)
expect_true(sum(latent$counts[latent$date > 21]) / 2000 < 0.01)
expect_true(abs(weighted.mean(latent$date, latent$counts) - 12) < 0.2)

# Negative standard deviations are rejected
expect_error(
  ModelMeaslesSchool(n = 10, prevalence = 1, rash_period_sd = -1)
)
