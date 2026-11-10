# Test just this file: tinytest::run_test_file("inst/tinytest/test-quarantine-exempt-tools.R")

# Who skips quarantine is set by tool name: by default the MMR vaccine
# (routine or as PEP), not any tool. Here everyone holds a tool with no effect
# ("Other"), as an immunoglobulin recipient would: traced contacts are
# quarantined, until "Other" joins the exempt tools.
n <- 2000
model <- measles::ModelMeaslesMixing(
  n                            = n,
  prevalence                   = 10 / n,
  transmission_rate            = 0.2,
  vax_efficacy                 = 0.9,
  hospitalization_rate         = 0,
  days_undetected              = 1,
  quarantine_period            = 21,
  quarantine_willingness       = 1,
  isolation_willingness        = 1,
  isolation_period             = 4,
  prop_vaccinated              = 0,
  contact_tracing_success_rate = 1,
  contact_tracing_days_window  = 4
)

add_layer(
  model,
  layer_mixing(
    "mixing",
    groups         = assign_counts(n),
    contact_matrix = matrix(10)
  )
)
add_tool(model, tool("Other", 0, 0, 0, 0), assign_share(1))
verbose_off(model)

expect_equal(get_quarantine_exempt_tools(model), c("MMR", "PEP MMR"))

# Agent-days in quarantine
quarantined <- function() {
  run(model, ndays = 60, seed = 1)
  totals <- get_hist_total(model)
  sum(totals$counts[totals$status == "Quarantined"])
}

expect_true(quarantined() > 0)

set_quarantine_exempt_tools(model, c("MMR", "PEP MMR", "Other"))
expect_equal(
  get_quarantine_exempt_tools(model),
  c("MMR", "PEP MMR", "Other")
)
expect_equal(quarantined(), 0)

# Errors
expect_error(set_quarantine_exempt_tools(model, 1), "character vector")
expect_error(
  set_quarantine_exempt_tools(epiworldR::Model(10), "MMR"),
  "not a measles model"
)
