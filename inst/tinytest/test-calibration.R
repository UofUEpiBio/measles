# Contact matrix
cmat <- c(
  10, 5, 2,
  5, 10, 5,
  2, 5, 10
) |> matrix(nrow = 3, byrow = TRUE)

r0 <- 4

# Calibrating for a measles model with R0 of 10
# assuming agents are infectious during prodomal stage
# (isolated during rash stage)
calib_val <- calibrate_mixing_model(
  contact_matrix = cmat,
  target_rep_number = r0,
  infectious_period_days = 4,
  transmission_prob = 0.2
)

# Should match the expected R0 from the multigroup.vaccine package
expected_r0 <- multigroup.vaccine::vaxrepnum(
  meaninf = 4,
  popsize = c(200, 100, 2700),
  trmat = cmat * 0.2 * calib_val,
  initR = rep(0, 3),
  initV = rep(0, 3),
  vaxeff = 0
)

expect_equal(r0, expected_r0)

# Now we test it empirically by running a simulation with the calibrated
# transmission rate (scaling factor applied to transmission_rate) and checking
# the average reproduction number across simulations.
m_model <- ModelMeaslesMixing(
  n = 3000,
  prevalence = 1 / 3000,
  transmission_rate = 0.2 * calib_val,
  vax_efficacy = 0.97,
  contact_matrix = cmat,
  hospitalization_rate = 0.05,
  hospitalization_period = 7,
  days_undetected = 2,
  prop_vaccinated = 0
)

add_entities_from_dataframe(
  model = m_model,
  entities = data.frame(
    id = as.character(1:3),
    size = as.integer(c(200, 100, 2700))
  ),
  col_name = "id",
  col_number = "size",
  as_proportion = FALSE
)

run_multiple(
  m_model,
  ndays = 100,
  nsims = 500,
  seed = 10203,
  saver = make_saver("reproductive"),
  nthreads = 2L
)

summary(m_model)

ans <- run_multiple_get_results(m_model)$reproductive

ans <- subset(ans, source != -1 & source_exposure_date == 0)

expect_equal(mean(ans$rt), r0, tol = 0.5)

# ===========================================
# Calibration with MeaslesMixing when agents
# with rash can be infectious but with reduced
# contact rates

set_param(m_model, "Rash reduction contact rate", .8)
set_param(m_model, "Days undetected", -1) # Deactivating
set_param(m_model, "Quarantine period", -1) # Deactivating

# Homogenizing so it is easier to check
# the calibration empirically
epiworldR::set_contact_matrix(
  m_model, 
  cmat * 0 + 4
)

run_multiple(
  m_model,
  ndays = 100,
  nsims = 500,
  seed = 10203,
  saver = make_saver("reproductive"),
  nthreads = 2L
)

ans <- run_multiple_get_results(m_model)$reproductive

ans <- subset(ans, source != -1 & source_exposure_date == 0)

# Computing the expected R0
r0 <- (4 * 3) * get_param(m_model, "Transmission rate") * (
  get_param(m_model, "Prodromal period") +
  (1 - get_param(m_model, "Rash reduction contact rate")) *
    get_param(m_model, "Rash period")
)

expect_equal(mean(ans$rt), r0, tol = 0.5)


