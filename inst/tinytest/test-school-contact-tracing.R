# Test just this file:
# tinytest::run_test_file("inst/tinytest/test-school-contact-tracing.R")

# In ModelMeaslesSchool(), the contacts sampled during transmission are
# recorded for contact tracing after sampling (post-sampling dispatch). The
# school model quarantines the whole school, so the recorded contacts are
# used by InterventionMeaslesPEP(): PEP is only offered if an identified case
# has a recorded encounter with the school while infectious, which dates the
# exposure. If the contacts were not recorded, PEP would never be offered.

run_school_pep <- function(contact_rate, seed) {

  model <- ModelMeaslesSchool(
    n               = 200,
    prevalence      = 1,
    contact_rate    = contact_rate,
    prop_vaccinated = 0
  )

  verbose_off(model)

  add_globalevent(
    model,
    InterventionMeaslesPEP(
      name                      = "PEP",
      mmr_efficacy              = 1,
      ig_efficacy               = 1,
      ig_half_life_mean         = 30,
      ig_half_life_sd           = 1,
      mmr_willingness           = 1,
      ig_willingness            = 0,
      mmr_window                = 365,
      ig_window                 = 0,
      target_states             = c(6L, 7L, 8L),
      states_if_pep_effective   = c(11L, 0L, 11L),
      states_if_pep_ineffective = c(1L, 0L, 2L)
    )
  )

  run(model, ndays = 60, seed = seed)

  # Number of agents holding the PEP MMR (maximum over days)
  hist_tool <- get_hist_tool(model)
  hist_tool <- hist_tool[hist_tool$tool == "PEP MMR", ]
  n_pep <- if (nrow(hist_tool)) {
    max(tapply(hist_tool$counts, hist_tool$date, sum))
  } else {
    0
  }

  # Was any case identified (moved to isolation or hospitalized)?
  trans <- get_hist_transition_matrix(model)
  identified <- any(
    trans$state_to %in% c("Isolated", "Hospitalized") &
      trans$state_from != trans$state_to &
      trans$counts > 0
  )

  list(n_pep = n_pep, identified = identified)

}

for (seed in c(1, 2, 3)) {

  # With contacts, the index case is recorded meeting the school, so PEP is
  # offered once it is identified
  with_contacts <- run_school_pep(contact_rate = 4, seed = seed)
  expect_true(with_contacts$identified, info = paste("seed", seed))
  expect_true(with_contacts$n_pep > 0, info = paste("seed", seed))

  # Without contacts, the index case is still identified, but it has no
  # recorded encounter with the school, so nobody is offered PEP
  no_contacts <- run_school_pep(contact_rate = 1e-10, seed = seed)
  expect_true(no_contacts$identified, info = paste("seed", seed))
  expect_equal(no_contacts$n_pep, 0, info = paste("seed", seed))

}
