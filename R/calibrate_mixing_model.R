
#' Calibrate a mixing model to a target reproduction number
#'
#' Uses the [epiworldR::compute_reproduction_number()] function to
#' optimize the scaling factor of the contact matrix to match a target
#' reproduction number.
#'
#' @param contact_matrix A contact matrix to be calibrated.
#' @param target_rep_number The target reproduction number to calibrate to.
#' @param infectious_period_days The average number of days an individual is
#' infectious.
#' @param transmission_prob The probability of transmission per contact.
#' @param ... Additional arguments to pass to [stats::optimize()].
#' @importFrom stats optimize
#' @return
#' The scaling factor for the contact matrix that achieves the target
#' reproduction number.
#' @examples
#' data(short_creek_matrix, package = "measles")
#'
#' # Calibrating for a measles model with R0 of 10
#' # assuming agents are infectious during prodomal stage
#' # (isolated during rash stage)
#' calibrate_mixing_model(
#'   contact_matrix = short_creek_matrix,
#'   target_rep_number = 10,
#'   infectious_period_days = 4,
#'   transmission_prob = 0.2
#' )
#'
#' # You can then use the scaling factor in a mixing
#' # model. Instead of using the original contact matrix,
#' # you would use:
#' #   contact_matrix * scaling_factor
#' @export
calibrate_mixing_model <- function(
  contact_matrix,
  target_rep_number,
  infectious_period_days,
  transmission_prob,
  ...
) {

  fun <- function(s) {
    r_expected <- epiworldR::compute_reproduction_number(
      contact_matrix = contact_matrix * s,
      transmission_prob = transmission_prob,
      infectious_period_days = infectious_period_days,
      infectiousness = NULL,
      susceptibility = NULL,
      check_reciprocity = FALSE
    )$R

    (r_expected - target_rep_number)^2
  }

  stats::optimize(
    f = fun,
    interval = c(0, 1000),
    ...
  )$minimum

}
