
# An in a school with low vaccination
R0s <- c(0.8, 1.25, 3.5)
for (R0 in R0s) {
  p_t <- .5
  p_r <- 1/7

  crate <- R0 / p_t * p_r

  model_measles <- measles::ModelMeaslesSchool(
    n = 1000,
    prevalence = 2,
    contact_rate = crate,
    transmission_rate = p_t,
    prodromal_period = 1/p_r,
    prop_vaccinated = 0,
    quarantine_period = -1
  ) |>
    verbose_off()

  # Running and printing
  saver <- make_saver("reproductive")
  run_multiple(
    model_measles, ndays = 100,
    seed = 1912,
    saver = saver,
    nsims = 500,
    nthreads = 2L
    )

  res <- run_multiple_get_results(model_measles, nthreads = 2L)

  # Identifying the date 0
  r0s <- res$reproductive
  r0s <- subset(r0s, source_exposure_date == 0 & source != -1)
  r0_obs <- r0s$rt |> mean()

  msg <- paste0("R0: ", R0, " observed: ", r0_obs)
  print(expect_true(abs(r0_obs - R0) < 0.2, info = msg))

}
