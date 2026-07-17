# Test just this file: tinytest::run_test_file("inst/tinytest/test-contact-matrix.R")

# get_contact_matrix() and set_contact_matrix() are provided by epiworldR
# (>= 0.15.1) and operate on the measles model classes directly. This test
# verifies that measles models remain compatible with those accessors.

# Helper function to create a random contact matrix
create_random_contact_matrix <- function(n) {
  mat <- matrix(runif(n * n), nrow = n, ncol = n)
  mat <- mat / rowSums(mat)
  mat * runif(n, min = 5, max = 20)
}

N <- 3000
identity_matrix <- diag(3) * 15

# ------------------------------------------------------------------------------
# ModelMeaslesMixing
# ------------------------------------------------------------------------------
model_mixing <- measles::ModelMeaslesMixing(
  n                          = N,
  prevalence                 = 1 / N,
  transmission_rate          = 0.9,
  vax_efficacy               = 0.97,
  vax_reduction_recovery_rate = 0.8,
  incubation_period          = 10,
  prodromal_period           = 3,
  rash_period                = 7,
  contact_matrix             = identity_matrix,
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

model_mixing |>
  add_entity(entity("Population 1", 1000, FALSE)) |>
  add_entity(entity("Population 2", 1000, FALSE)) |>
  add_entity(entity("Population 3", 1000, FALSE))

# Run the model first so the contact matrix is initialized
set.seed(123)
run(model_mixing, ndays = 10)

# Extracted matrix has the expected dimensions
expect_equal(dim(get_contact_matrix(model_mixing)), c(3, 3))

# Round-trip: setting a matrix and reading it back returns the same matrix
set.seed(456)
random_matrix <- create_random_contact_matrix(3)
set_contact_matrix(model_mixing, random_matrix)
expect_equal(get_contact_matrix(model_mixing), random_matrix, tolerance = 1e-10)

# ------------------------------------------------------------------------------
# ModelMeaslesMixingRiskQuarantine
# ------------------------------------------------------------------------------
model_risk_quar <- measles::ModelMeaslesMixingRiskQuarantine(
  n                          = N,
  prevalence                 = 1 / N,
  transmission_rate          = 0.9,
  vax_efficacy               = 0.97,
  incubation_period          = 10,
  prodromal_period           = 3,
  rash_period                = 7,
  contact_matrix             = identity_matrix,
  hospitalization_rate       = 0.1,
  hospitalization_period     = 10,
  days_undetected            = 2,
  quarantine_period_high     = 21,
  quarantine_period_medium   = 14,
  quarantine_period_low      = 7,
  quarantine_willingness     = 0.9,
  isolation_willingness      = 0.8,
  isolation_period           = 10,
  prop_vaccinated            = 0.95,
  detection_rate_quarantine  = 0.5,
  contact_tracing_success_rate = 0.8,
  contact_tracing_days_window = 4
)

model_risk_quar |>
  add_entity(entity("Population 1", 1000, FALSE)) |>
  add_entity(entity("Population 2", 1000, FALSE)) |>
  add_entity(entity("Population 3", 1000, FALSE))

# Run the model first so the contact matrix is initialized
set.seed(789)
run(model_risk_quar, ndays = 10)

expect_equal(dim(get_contact_matrix(model_risk_quar)), c(3, 3))

set.seed(101112)
random_matrix_rq <- create_random_contact_matrix(3)
set_contact_matrix(model_risk_quar, random_matrix_rq)
expect_equal(get_contact_matrix(model_risk_quar), random_matrix_rq, tolerance = 1e-10)
