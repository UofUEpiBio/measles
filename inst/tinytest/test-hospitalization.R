set.seed(312)

p_hosp <- 0.1
p_rec <- 1/3

# Adjusting hospitalization rate for testing purposes
hosp_rate <- p_hosp * (1-p_rec) / (1 - p_hosp)

m_model <- ModelMeaslesSchool(
  n = 500L,
  prevalence = 1,
  rash_period = as.integer(1/p_rec),
  hospitalization_rate = hosp_rate,
  prop_vaccinated = 0.5,
  quarantine_period = -1
)

run_multiple(
  m_model,
  ndays = 200,
  nsims = 1000,
  saver = make_saver("transition", "outbreak_size", "transmission"),
  nthreads = 2,
  seed = 1123
)

ans <- run_multiple_get_results(
  m_model, freader = data.table::fread, nThread = 4, nthreads = 1L)

library(data.table)
ans_transition <- ans$transition
ans_outbreak_size <- ans$outbreak_size
ans_transmission <- ans$transmission

mean_o_s_transmission <- ans_transmission[, .N, by = "sim_num"]

mean_o_s <- ans_outbreak_size[date == max(date)][,
  outbreak_size, by = .(sim_num)]

expect_equal(mean_o_s_transmission$N, mean_o_s$outbreak_size)

to_hosp <- ans_transition[
  (from %in% c("Rash", "Isolated")) &
  (to %in% c("Hospitalized", "Detected Hospitalized"))][, .(hosp = sum(counts)), by = .(sim_num)]

to_hosp <- merge(
  to_hosp,
  data.table(sim_num = 1L:nrow(mean_o_s)),
  all = TRUE
  )

to_hosp[, hosp:= fcoalesce(hosp, 0L)]

ans <- merge(mean_o_s, to_hosp)

if (interactive()) {
  message(
    "Mean outbreak size      : ", round(mean(ans$outbreak_size), 2), "\n",
    "Mean hospitalizations   : ", round(mean(ans$hosp), 2), "\n",
    "Proportion hospitalized : ", round(mean(ans$hosp/ans$outbreak_size), 2), "\n",
    "Quantiles [.025, 0.5, .975]  : [", paste(
      ans[, quantile(hosp/outbreak_size, probs = c(.025, 0.5, .975))] |>
        round(2),
      collapse = "; "
    ), "]"
  )
}

expect_true(
  abs(mean(ans$hosp/ans$outbreak_size) - p_hosp) < .1
)