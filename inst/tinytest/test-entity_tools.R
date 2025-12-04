entities <- data.frame(
  name = c("Pop 1", "Pop 2", "Pop 3"),
  size = rep(3e3, 3)
)

# Row-stochastic matrix (rowsums 1)
cmatrix <- c(
  c(0.9, 0.05, 0.05),
  c(0.1, 0.8, 0.1),
  c(0.1, 0.2, 0.7)
) |> matrix(byrow = TRUE, nrow = 3)

measles_model <- ModelMeaslesMixing(
  n               = 9000,
  prevalence      = 1 / 9000,
  contact_rate    = 15,
  contact_matrix  = cmatrix,
  prop_vaccinated = .8
) |>
  entities_from_dataframe(
    entities = entities,
    col_name = "name",
    col_number = "size",
    as_proportion = FALSE
  ) |>
  verbose_off()

# Running the model to get the entities
run(measles_model, ndays=10, seed=1)

entities_obj <- get_entities(measles_model)

# Getting the entity distribution
esizes <- sapply(entities_obj, \(e) nrow(entity_get_agents(e)))
expect_true(all(esizes == 3000))

# Should be unique distributions
lapply(entities_obj, \(e) entity_get_agents(e)[,1]) |>
  unlist(recursive = FALSE) |>
  unique() |>
  length() |>
  expect_equal(9000)

# Checking names
enames <- entities_obj |> sapply(get_entity_name)
expect_equal(enames, entities$name)