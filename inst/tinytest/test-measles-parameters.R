# Test just this file:
# tinytest::run_test_file("inst/tinytest/test-measles-parameters.R")

params <- measles_parameters()

# ------------------------------------------------------------------------------
# Structure of the table
# ------------------------------------------------------------------------------
expect_true(is.data.frame(params))
expect_equal(
  colnames(params),
  c(
    "parameter", "r_argument", "models", "default", "units", "type",
    "lit_low", "lit_high", "description", "citation", "doi_or_url", "notes"
  )
)
expect_false(anyDuplicated(params$parameter) > 0)
expect_true(all(params$type %in% c("probability", "rate", "days", "count")))
expect_true(all(nzchar(params$citation)))

# Links are URLs
links <- params$doi_or_url[nzchar(params$doi_or_url)]
expect_true(all(grepl("^https://", links)))

# ------------------------------------------------------------------------------
# Filtering by model
# ------------------------------------------------------------------------------
school <- measles_parameters("ModelMeaslesSchool")
expect_true(all(grepl("ModelMeaslesSchool", school$models)))
expect_true("contact_rate" %in% school$r_argument)
expect_false("contact_matrix" %in% school$r_argument)
expect_error(measles_parameters("NotAModel"), "No parameters found")

# ------------------------------------------------------------------------------
# Drift test: the table matches the arguments and defaults of the models
# ------------------------------------------------------------------------------
not_parameters <- c(
  "...", "name", "target_states", "states_if_pep_effective",
  "states_if_pep_ineffective", "agent_groups"
)

for (model in c(
  "ModelMeaslesSchool", "ModelMeaslesMixing",
  "ModelMeaslesMixingRiskQuarantine", "InterventionMeaslesPEP"
)) {

  fmls <- formals(get(model, envir = asNamespace("measles")))
  fmls <- fmls[setdiff(names(fmls), not_parameters)]
  tab  <- measles_parameters(model)

  # Every argument has a row, and every row is an argument
  expect_equal(sort(tab$r_argument), sort(names(fmls)), info = model)

  # Defaults match (skipping arguments without a default)
  for (arg in names(fmls)) {

    if (identical(fmls[[arg]], quote(expr = )))
      next

    csv_default <- tab$default[tab$r_argument == arg]
    expect_identical(
      str2lang(csv_default), fmls[[arg]],
      info = sprintf("%s(%s = %s)", model, arg, csv_default)
    )

  }

}
