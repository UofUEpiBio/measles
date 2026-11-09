# The measles models are built by their entries in epiworld's model registry
# (measles::register_models()), which check the values of the arguments; the
# named constructors give them their names in R.
new_measles_model <- function(id, values) {

  v <- as.double(unlist(values))
  names(v) <- names(values)

  structure(
    make_model_cpp(id, v),
    class = c(paste0("epiworld_", tolower(id)), "epiworld_model")
  )

}
