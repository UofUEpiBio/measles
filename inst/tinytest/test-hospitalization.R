set.seed(312)

p_hosp <- 0.15
p_rec <- 1/4

# Adjusting hospitalization rate for testing purposes
hosp_rate <- p_hosp * p_rec / (1 - p_hosp)

m_model <- ModelMeaslesSchool(
  n = 500L,
  prevalence = 1,
  rash_period = as.integer(1/p_rec),
  hospitalization_rate = hosp_rate,
  prop_vaccinated = 0
)

run_multiple(
  m_model,
  ndays = 200,
  nsims = 200,
  saver = make_saver("transition", "virus_hist", "total_hist", "outbreak_size"),
  nthreads = 8,
  seed = 1123
)



ans <- run_multiple_get_results(m_model)

library(data.table)
ans_transition <- ans$transition |> as.data.table()
ans_virus_hist <- ans$virus_hist |> as.data.table()
ans_total_hist <- ans$total_hist |> as.data.table()

ans_virus_hist[
  date == max(date),
  .(n_cases = sum(n)),
  by = .(sim_num)
][, mean(n_cases)]

to_hosp <- ans_transition[from != "Hospitalized" & to == "Hospitalized"]
to_hosp[, sum(counts), by = .(sim_num)][, mean(V1)]
