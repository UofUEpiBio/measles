# Test just this file: tinytest::run_test_file("inst/tinytest/test-measlesmixing.R")
# Row-stochastic matrix (rowsums 1)
cmatrix <- (c(
  c(1, 0, 0),
  c(0, 1, 0),
  c(0, 0, 1)
) * 15) |> as.double() |> matrix(byrow = TRUE, nrow = 3)

N <- 9e3

measles_model <- measles::ModelMeaslesMixing(
  n                          = N,
  prevalence                 = 1 / N,
  transmission_rate          = 0.9,
  vax_efficacy               = 0.97,
  vax_reduction_recovery_rate = 0.8,
  incubation_period          = 10,
  prodromal_period           = 3,
  rash_period                = 7,
  hospitalization_rate       = 0.1,
  hospitalization_period     = 10,
  days_undetected            = 2,
  quarantine_period          = 14,
  quarantine_willingness     = 0.9,
  isolation_willingness      = 0.8,
  isolation_period           = 10,
  prop_vaccinated            = 0.95,
  contact_tracing_success_rate = 0.8,
  contact_tracing_days_window = 4
)

# Three groups of 3,000, drawn at random at every run
add_layer(
  measles_model,
  layer_mixing(
    "mixing",
    groups         = grouping_random(c(3e3, 3e3, 3e3)),
    contact_matrix = cmatrix
  )
)

run(measles_model, ndays = 100, seed = 1233)
summary(measles_model)

library(data.table)

transmissions <- get_transmissions(measles_model) |>
  data.table()

# The group of each case, from the mixing layer
mixing <- get_layer(measles_model, "mixing")
transmissions[, group := vapply(target, get_group, integer(1), layer = mixing)]

# Aggregating by date x group (counts)
transmissions <- transmissions[, .N, by = .(date, group)]

transmissions[, sum(N), by = .(group)]

transmissions[, table(group)]

# Check functions fail with invalid inputs -------------------------------------
good_n <- 9e3
good_prevalence <- 1 / good_n
good_transmission_rate <- 0.9
good_vax_efficacy <- 0.97
good_vax_reduction_recovery_rate <- 0.8
good_incubation_period <- 10
good_prodromal_period <- 3
good_rash_period <- 7
good_hospitalization_rate <- 0.1
good_hospitalization_period <- 10
good_days_undetected <- 2
good_quarantine_period <- 14L
good_quarantine_willingness <- 0.9
good_isolation_willingness <- 0.8
good_isolation_period <- 10L
good_prop_vaccinated <- 0.95
good_contact_tracing_success_rate <- 0.8
good_contact_tracing_days_window <- 4L

bad_numeric_input <- "not a number"
bad_int_input <- "not an integer"

expected_error_msg_na <- "must not be NA"
expected_error_msg_str <- "must be a string"
expected_error_msg_int <- "must be an integer"
expected_error_msg_double <- "must be a double"

expect_error(test_model <- measles::ModelMeaslesMixing(
  n                          = bad_numeric_input,
  prevalence                 = good_prevalence,
  transmission_rate          = good_transmission_rate,
  vax_efficacy               = good_vax_efficacy,
  vax_reduction_recovery_rate = good_vax_reduction_recovery_rate,
  incubation_period          = good_incubation_period,
  prodromal_period           = good_prodromal_period,
  rash_period                = good_rash_period,
  hospitalization_rate       = good_hospitalization_rate,
  hospitalization_period     = good_hospitalization_period,
  days_undetected            = good_days_undetected,
  quarantine_period          = good_quarantine_period,
  quarantine_willingness     = good_quarantine_willingness,
  isolation_willingness      = good_isolation_willingness,
  isolation_period           = good_isolation_period,
  prop_vaccinated            = good_prop_vaccinated,
  contact_tracing_success_rate = good_contact_tracing_success_rate,
  contact_tracing_days_window = good_contact_tracing_days_window
), expected_error_msg_int)

expect_error(test_model <- ModelMeaslesMixing(
  n                          = good_n,
  prevalence                 = bad_numeric_input,
  transmission_rate          = good_transmission_rate,
  vax_efficacy               = good_vax_efficacy,
  vax_reduction_recovery_rate = good_vax_reduction_recovery_rate,
  incubation_period          = good_incubation_period,
  prodromal_period           = good_prodromal_period,
  rash_period                = good_rash_period,
  hospitalization_rate       = good_hospitalization_rate,
  hospitalization_period     = good_hospitalization_period,
  days_undetected            = good_days_undetected,
  quarantine_period          = good_quarantine_period,
  quarantine_willingness     = good_quarantine_willingness,
  isolation_willingness      = good_isolation_willingness,
  isolation_period           = good_isolation_period,
  prop_vaccinated            = good_prop_vaccinated,
  contact_tracing_success_rate = good_contact_tracing_success_rate,
  contact_tracing_days_window = good_contact_tracing_days_window
), expected_error_msg_double)

# The model needs its mixing layer
no_layer <- ModelMeaslesMixing(
  n                            = good_n,
  prevalence                   = good_prevalence,
  prop_vaccinated              = good_prop_vaccinated
)
expect_error(run(no_layer, ndays = 1, seed = 1), "mixing layer")

expect_error(test_model <- ModelMeaslesMixing(
  n                          = good_n,
  prevalence                 = good_prevalence,
  transmission_rate          = good_transmission_rate,
  vax_efficacy               = good_vax_efficacy,
  vax_reduction_recovery_rate = good_vax_reduction_recovery_rate,
  incubation_period          = good_incubation_period,
  prodromal_period           = good_prodromal_period,
  rash_period                = good_rash_period,
  hospitalization_rate       = bad_numeric_input,
  hospitalization_period     = good_hospitalization_period,
  days_undetected            = good_days_undetected,
  quarantine_period          = good_quarantine_period,
  quarantine_willingness     = good_quarantine_willingness,
  isolation_willingness      = good_isolation_willingness,
  isolation_period           = good_isolation_period,
  prop_vaccinated            = good_prop_vaccinated,
  contact_tracing_success_rate = good_contact_tracing_success_rate,
  contact_tracing_days_window = good_contact_tracing_days_window
), expected_error_msg_double)

expect_error(test_model <- ModelMeaslesMixing(
  n                          = good_n,
  prevalence                 = good_prevalence,
  transmission_rate          = good_transmission_rate,
  vax_efficacy               = good_vax_efficacy,
  vax_reduction_recovery_rate = good_vax_reduction_recovery_rate,
  incubation_period          = good_incubation_period,
  prodromal_period           = good_prodromal_period,
  rash_period                = good_rash_period,
  hospitalization_rate       = good_hospitalization_rate,
  hospitalization_period     = good_hospitalization_period,
  days_undetected            = good_days_undetected,
  quarantine_period          = bad_int_input,
  quarantine_willingness     = good_quarantine_willingness,
  isolation_willingness      = good_isolation_willingness,
  isolation_period           = good_isolation_period,
  prop_vaccinated            = good_prop_vaccinated,
  contact_tracing_success_rate = good_contact_tracing_success_rate,
  contact_tracing_days_window = good_contact_tracing_days_window
), expected_error_msg_int)

expect_error(test_model <- ModelMeaslesMixing(
  n                          = good_n,
  prevalence                 = good_prevalence,
  transmission_rate          = good_transmission_rate,
  vax_efficacy               = good_vax_efficacy,
  vax_reduction_recovery_rate = good_vax_reduction_recovery_rate,
  incubation_period          = good_incubation_period,
  prodromal_period           = good_prodromal_period,
  rash_period                = good_rash_period,
  hospitalization_rate       = good_hospitalization_rate,
  hospitalization_period     = good_hospitalization_period,
  days_undetected            = NA,
  quarantine_period          = good_quarantine_period,
  quarantine_willingness     = good_quarantine_willingness,
  isolation_willingness      = good_isolation_willingness,
  isolation_period           = good_isolation_period,
  prop_vaccinated            = good_prop_vaccinated,
  contact_tracing_success_rate = good_contact_tracing_success_rate,
  contact_tracing_days_window = good_contact_tracing_days_window
), expected_error_msg_na)

# Test bound checks for probability parameters
expect_error(test_model <- ModelMeaslesMixing(
  n                          = good_n,
  prevalence                 = good_prevalence,
  transmission_rate          = good_transmission_rate,
  vax_efficacy               = 1.5, # Invalid: > 1
  vax_reduction_recovery_rate = good_vax_reduction_recovery_rate,
  incubation_period          = good_incubation_period,
  prodromal_period           = good_prodromal_period,
  rash_period                = good_rash_period,
  hospitalization_rate       = good_hospitalization_rate,
  hospitalization_period     = good_hospitalization_period,
  days_undetected            = good_days_undetected,
  quarantine_period          = good_quarantine_period,
  quarantine_willingness     = good_quarantine_willingness,
  isolation_willingness      = good_isolation_willingness,
  isolation_period           = good_isolation_period,
  prop_vaccinated            = good_prop_vaccinated,
  contact_tracing_success_rate = good_contact_tracing_success_rate,
  contact_tracing_days_window = good_contact_tracing_days_window
), "must be")

expect_error(test_model <- ModelMeaslesMixing(
  n                          = good_n,
  prevalence                 = good_prevalence,
  transmission_rate          = good_transmission_rate,
  vax_efficacy               = good_vax_efficacy,
  vax_reduction_recovery_rate = good_vax_reduction_recovery_rate,
  incubation_period          = good_incubation_period,
  prodromal_period           = good_prodromal_period,
  rash_period                = good_rash_period,
  hospitalization_rate       = good_hospitalization_rate,
  hospitalization_period     = good_hospitalization_period,
  days_undetected            = good_days_undetected,
  quarantine_period          = good_quarantine_period,
  quarantine_willingness     = -0.1, # Invalid: < 0
  isolation_willingness      = good_isolation_willingness,
  isolation_period           = good_isolation_period,
  prop_vaccinated            = good_prop_vaccinated,
  contact_tracing_success_rate = good_contact_tracing_success_rate,
  contact_tracing_days_window = good_contact_tracing_days_window
), "must be")
