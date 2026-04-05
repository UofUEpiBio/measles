
#' Create a measles post-exposure prophylaxis (PEP) intervention
#'
#'
#' @param name Name of the intervention.
#' @param mmr_efficacy Probability of MMR vaccine efficacy.
#' @param ig_efficacy Probability of immunoglobulin (IG) efficacy.
#' @param ig_half_life_mean Mean of the half-life of immunoglobulin (IG) in days.
#' @param ig_half_life_sd Standard deviation of the half-life of immunoglobulin (IG) in days.
#' @param pep_willingness Probability that an individual will accept PEP.
#' @param mmr_window Time window for MMR vaccine administration.
#' @param quarantine_states,quarantine_states_for_pep Character vector of target and destination states (see details).
#'
#' @details
#' This functions creates a global event that represents a post-exposure
#' prophylaxis (PEP) intervention for measles. The intervention includes the
#' administration of MMR vaccine and immunoglobulin (IG) to individuals who
#' have been exposed to the virus, with the goal of reducing the probability
#' of infection and preventing the spread of the disease.
#'
#' The process involves both PEP Measles-Mumps-Rubella (MMR) vaccine and
#' immunoglobulin (IG). The system decides which agent gets MMR or IG
#' based on the time since exposure and the willingness to accept PEP.
#' The flow is the following:
#'
#' 1. Agents in `quarantine_states` are eligible for PEP if they are
#' willing to accept it (based on `pep_willingness`).
#'
#' 2. If the agent has been exposed (has the virus in their system)
#' for at most `mmr_window` days, they are offered MMR vaccine.
#' Otherwise, they are offered IG.
#'
#' 3. Unexposed agents are offered the MMR vaccine, and if they accept,
#' they are automatically moved out of the quarantine process.
#'
#' 4. Agents who were exposed and got either MMR of IG may move
#' out of the quarantine process if the PEP is effective (based on
#' `mmr_efficacy` or `ig_efficacy`).
#'
#' Since IG winds down over time, the IG "tool" may be removed from
#' the agent as a function of the half-life of IG (based on
#' `ig_half_life_mean` and `ig_half_life_sd`). Particularly, after
#' applied, the IG "tool" will have a random duration based on a normal
#' distribution with mean `ig_half_life_mean` and standard deviation
#' `ig_half_life_sd`. Once the duration is over, the IG "tool" is removed
#' from the agent, and they are again eligible for PEP if they
#' get exposed again.
#'
#' @returns
#' An object of class `epiworld_globalevent` representing the measles PEP
#' intervention.
#'
InterventionMeaslesPEP <- function(
  name,
  mmr_efficacy,
  ig_efficacy,
  ig_half_life_mean,
  ig_half_life_sd,
  pep_willingness,
  mmr_window,
  quarantine_states,
  quarantine_states_for_pep
) {

  stopifnot_double(mmr_efficacy, lb = 0, ub = 1)
  stopifnot_double(ig_efficacy, lb = 0, ub = 1)
  stopifnot_double(ig_half_life_mean, lb = 0)
  stopifnot_double(ig_half_life_sd, lb = 0)
  stopifnot_double(pep_willingness, lb = 0, ub = 1)
  stopifnot_double(mmr_window, lb = 0)
  stopifnot_character(quarantine_states)
  stopifnot_character(quarantine_states_for_pep)

  InterventionMeaslesPEP_cpp(
    name,
    mmr_efficacy,
    ig_efficacy,
    ig_half_life_mean,
    ig_half_life_sd,
    pep_willingness,
    mmr_window,
    quarantine_states,
    quarantine_states_for_pep
  ) |>
    structure(class = c("epiworld_globalevent"))

}
