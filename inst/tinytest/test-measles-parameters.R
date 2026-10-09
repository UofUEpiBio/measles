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

# ------------------------------------------------------------------------------
# Printing fuses the argument and units columns
# ------------------------------------------------------------------------------
expect_inherits(params, "measles_parameters")
expect_inherits(params[, c("parameter", "default")], "measles_parameters")

fmt <- format(params)
expect_true(is.data.frame(fmt))
expect_false(inherits(fmt, "measles_parameters"))
expect_equal(
  colnames(fmt)[1:4],
  c("Parameter (argument)", "models", "Default (units)", "type")
)
expect_false(any(c("r_argument", "units") %in% colnames(fmt)))

tr <- which(params$r_argument == "transmission_rate")
expect_equal(fmt[tr, "Parameter (argument)"], "Transmission rate (transmission_rate)")
expect_equal(fmt[tr, "Default (units)"], "0.9 (per contact)")

# Rows without an argument show the name only
r0 <- which(params$parameter == "R0")
expect_equal(fmt[r0, "Parameter (argument)"], "R0")

# Markdown: code, links, and escaped pipes
md <- format(params, markdown = TRUE)
expect_equal(md[tr, "Parameter (argument)"], "Transmission rate (`transmission_rate`)")
expect_equal(md[tr, "Default (units)"], "`0.9` (per contact)")
expect_false("doi_or_url" %in% colnames(md))
expect_true(grepl("[link](https://", md[tr, "Source (and notes)"], fixed = TRUE))

# Notes are folded into the source
expect_false(any(c("citation", "notes") %in% colnames(fmt)))
expect_equal(
  fmt[tr, "Source (and notes)"],
  paste0(params$citation[tr], " (Note: ", params$notes[tr], ")")
)
no_note <- which(!nzchar(params$notes))[1]
expect_equal(fmt[no_note, "Source (and notes)"], params$citation[no_note])

# The link goes right after the citation, before the note
expect_true(grepl(
  paste0("([link](", params$doi_or_url[tr], ")) (Note: "),
  md[tr, "Source (and notes)"], fixed = TRUE
))

# Pairs are fused only when both columns are present
sub <- format(params[, c("r_argument", "default")])
expect_equal(colnames(sub), c("r_argument", "default"))

expect_stdout(print(params[, c("parameter", "r_argument")]), "Parameter \\(argument\\)")
