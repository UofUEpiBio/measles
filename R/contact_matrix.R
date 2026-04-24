#' Get and Set Contact Matrix
#'
#' These functions allow getting and setting the contact matrix for
#' measles mixing models. The contact matrix specifies the mixing patterns
#' between different population groups.
#'
#' @param model An epiworld model object of class `epiworld_measlesmixing` or
#'   `epiworld_measlesmixingriskquarantine`.
#' @param value A numeric square matrix representing contact rates between
#'   population groups. The matrix should have one row and one column per
#'   entity in the model.
#'
#' @return
#' - `get_contact_matrix()` returns a numeric matrix representing the contact
#'   rates between population groups.
#' - `set_contact_matrix()` returns the model object invisibly (called for
#'   its side effects).
#'
#' @details
#' Entry `[i, j]` of the contact matrix represents the expected number of
#' contacts that an individual in group `i` has with individuals in group `j`
#' during a time step.
#'
#' These functions are currently only available for:
#' - [ModelMeaslesMixing]
#' - [ModelMeaslesMixingRiskQuarantine]
#'
#' Other mixing models in epiworld will have these methods available in the
#' near future.
#'
#' @examples
#' # Create entities for three population groups
#' e1 <- entity("Population 1", 1000, as_proportion = FALSE)
#' e2 <- entity("Population 2", 1000, as_proportion = FALSE)
#' e3 <- entity("Population 3", 1000, as_proportion = FALSE)
#'
#' # Create an identity contact matrix (no mixing between groups)
#' cmatrix <- diag(3) * 15
#'
#' N <- 3000
#'
#' # Create a measles mixing model
#' model <- ModelMeaslesMixing(
#'   n                        = N,
#'   prevalence               = 1 / N,
#'   transmission_rate        = 0.9,
#'   vax_efficacy             = 0.97,
#'   vax_reduction_recovery_rate = 0.8,
#'   incubation_period        = 10,
#'   prodromal_period         = 3,
#'   rash_period              = 7,
#'   contact_matrix           = cmatrix,
#'   hospitalization_rate     = 0.1,
#'   hospitalization_period   = 10,
#'   days_undetected          = 2,
#'   quarantine_period        = 14,
#'   quarantine_willingness   = 0.9,
#'   isolation_willingness    = 0.8,
#'   isolation_period         = 10,
#'   prop_vaccinated          = 0.95,
#'   contact_tracing_success_rate = 0.8,
#'   contact_tracing_days_window = 4
#' )
#'
#' # Add entities to the model
#' model |>
#'   add_entity(e1) |>
#'   add_entity(e2) |>
#'   add_entity(e3)
#'
#' # Get the contact matrix (note: requires running the model first)
#' set.seed(123)
#' run(model, ndays = 10)
#' original_matrix <- get_contact_matrix(model)
#' print(original_matrix)
#'
#' # Create a new contact matrix
#' new_matrix <- matrix(
#'   c(12, 1.5, 1.5,
#'     2, 11, 2,
#'     2.25, 2.25, 10.5),
#'   nrow = 3, byrow = TRUE
#' )
#'
#' # Set the new contact matrix
#' set_contact_matrix(model, new_matrix)
#'
#' # Verify the change
#' updated_matrix <- get_contact_matrix(model)
#' print(updated_matrix)
#'
#' @name contact_matrix
#' @aliases get_contact_matrix set_contact_matrix
#' @export
get_contact_matrix <- function(model) {
  UseMethod("get_contact_matrix")
}

#' @rdname contact_matrix
#' @export
get_contact_matrix.default <- function(model) {
  stop(
    "get_contact_matrix() is not available for this model type. ",
    "Currently supported: epiworld_measlesmixing, ",
    "epiworld_measlesmixingriskquarantine",
    call. = FALSE
  )
}

#' @rdname contact_matrix
#' @export
get_contact_matrix.epiworld_measlesmixing <- function(model) {
  stopifnot_model(model)

  # Get the vector from C++ and convert to matrix
  # C++ stores the matrix in column-major order (same as R)
  vec <- get_contact_matrix_mixing_cpp(model)
  n <- sqrt(length(vec))
  matrix(vec, nrow = n, ncol = n)
}

#' @rdname contact_matrix
#' @export
get_contact_matrix.epiworld_measlesmixingriskquarantine <- function(model) {
  stopifnot_model(model)

  # Get the vector from C++ and convert to matrix
  # C++ stores the matrix in column-major order (same as R)
  vec <- get_contact_matrix_mixing_risk_quarantine_cpp(model)
  n <- sqrt(length(vec))
  matrix(vec, nrow = n, ncol = n)
}

#' @rdname contact_matrix
#' @export
set_contact_matrix <- function(model, value) {
  UseMethod("set_contact_matrix")
}

#' @rdname contact_matrix
#' @export
set_contact_matrix.default <- function(model, value) {
  stop(
    "set_contact_matrix() is not available for this model type. ",
    "Currently supported: epiworld_measlesmixing, ",
    "epiworld_measlesmixingriskquarantine",
    call. = FALSE
  )
}

#' @rdname contact_matrix
#' @export
set_contact_matrix.epiworld_measlesmixing <- function(model, value) {
  stopifnot_model(model)

  # Validate the matrix: must be numeric and contain non-negative rates.
  if (!is.matrix(value) || !is.numeric(value)) {
    stop("value must be a numeric matrix")
  }

  # Check that all values are greater than 0
  stopifnot_double(as.vector(value), lb = 0)

  # as.vector() converts matrix to column-major order (same as C++ expects)
  set_contact_matrix_mixing_cpp(model, as.vector(value))
  invisible(model)
}

#' @rdname contact_matrix
#' @export
set_contact_matrix.epiworld_measlesmixingriskquarantine <- function(model, value) {
  stopifnot_model(model)

  # Validate the matrix: must be numeric and contain non-negative rates.
  if (!is.matrix(value) || !is.numeric(value)) {
    stop("value must be a numeric matrix")
  }

  # Check that all values are greater than or equal to zero.
  stopifnot_double(as.vector(value), lb = 0)

  # as.vector() converts matrix to column-major order (same as C++ expects)
  set_contact_matrix_mixing_risk_quarantine_cpp(model, as.vector(value))
  invisible(model)
}
