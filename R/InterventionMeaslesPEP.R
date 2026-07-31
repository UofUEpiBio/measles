
#' Create a measles post-exposure prophylaxis (PEP) intervention
#'
#'
#' @param name Name of the intervention.
#' @param mmr_efficacy Probability of MMR vaccine efficacy.
#' @param ig_efficacy Probability of immunoglobulin (IG) efficacy.
#' @param ig_half_life_mean Mean of the half-life of immunoglobulin (IG) in
#' days.
#' @param ig_half_life_sd Standard deviation of the half-life of immunoglobulin
#' (IG) in days.
#' @param mmr_willingness Probability that an individual will accept MMR
#' vaccine.
#' @param ig_willingness Probability that an individual will accept
#' immunoglobulin (IG).
#' @param mmr_window Time window for MMR vaccine administration.
#' @param ig_window Time window for immunoglobulin (IG) administration.
#' @param target_states,states_if_pep_effective,states_if_pep_ineffective
#' Integer vectors of target and destination states (see details).
#' @param agent_groups Optional integer vector of group (e.g. classroom)
#' membership, with one entry per agent, in agent order. When supplied, PEP is
#' offered only within the group(s) of the identified case(s). Defaults to
#' `integer(0)`, meaning the whole population is treated as a single exposed
#' group (see details).
#'
#' @details
#' This functions creates a global event that represents a post-exposure
#' prophylaxis (PEP) intervention for measles. The intervention includes the
#' administration of MMR vaccine and immunoglobulin (IG) to individuals after
#' exposure to the virus, with the goal of reducing the probability
#' of infection and preventing the spread of the disease.
#'
#' The process involves both PEP Measles-Mumps-Rubella (MMR) vaccine and
#' immunoglobulin (IG). The system decides which agent gets MMR or IG
#' based on the time since exposure and the willingness to accept PEP.
#' The flow is the following:
#'
#' 1. Agents in `target_states` are eligible for PEP if they are
#' willing to accept it (based on `pep_willingness`).
#'
#' 2. If the agent is already infected (for example, in a latent state)
#' for at most `mmr_window` days, they are offered MMR vaccine.
#' Otherwise, they are offered IG.
#'
#' 3. Susceptible agents are offered the MMR vaccine, and if they accept,
#' they are automatically moved out of the quarantine process.
#'
#' 4. Agents who were already infected and got either MMR or IG may move
#' out of the quarantine process if the PEP is effective (based on
#' `mmr_efficacy` or `ig_efficacy`). The destination state depends
#' on whether the PEP was effective or not, and is determined by
#' `states_if_pep_effective` and `states_if_pep_ineffective`,
#'  respectively.
#'
#' Since IG winds down over time, the IG "tool" may be removed from
#' the agent as a function of the half-life of IG (based on
#' `ig_half_life_mean` and `ig_half_life_sd`). Particularly, after
#' applied, the IG "tool" will have a random duration based on a normal
#' distribution with mean `ig_half_life_mean` and standard deviation
#' `ig_half_life_sd`. Once the duration is over, the IG "tool" is removed
#' from the agent, and they are again eligible for PEP if they
#' are exposed again.
#'
#' # Who is offered PEP
#'
#' Public health rarely has time to trace individual contacts. When a case is
#' identified, the exposed group is treated as exposed as a whole, and the only
#' question is how long ago that exposure started. By default that group is the
#' entire population, which is appropriate for a single classroom but
#' misleading when the population is really a set of separate communities.
#'
#' `agent_groups` circumscribes the response. Supply one group label per agent,
#' in agent order, and PEP is offered only to agents sharing the label of an
#' identified case. Labels are arbitrary integers: agents with the same label
#' are in the same group. For example, with 60 agents in three classrooms,
#' `agent_groups = rep(1:3, each = 20)`. A vector whose length is neither zero
#' nor the number of agents is an error, since it is matched to agents by
#' position.
#'
#' Each group is also timed from its own exposure, so a case identified in one
#' classroom does not shorten (or extend) the window available to another.
#'
#' @returns
#' An object of class `epiworld_globalevent` representing the measles PEP
#' intervention.
#' @export
#' @seealso [epiworldR::global-events]
InterventionMeaslesPEP <- function(
  name,
  mmr_efficacy,
  ig_efficacy,
  ig_half_life_mean,
  ig_half_life_sd,
  mmr_willingness,
  ig_willingness,
  mmr_window,
  ig_window,
  target_states,
  states_if_pep_effective,
  states_if_pep_ineffective,
  agent_groups = integer(0)
) {

  stopifnot_character(name)
  stopifnot_double(mmr_efficacy, lb = 0, ub = 1)
  stopifnot_double(ig_efficacy, lb = 0, ub = 1)
  stopifnot_double(ig_half_life_mean, lb = 0)
  stopifnot_double(ig_half_life_sd, lb = 0)
  stopifnot_double(mmr_willingness, lb = 0, ub = 1)
  stopifnot_double(ig_willingness, lb = 0, ub = 1)
  stopifnot_double(mmr_window, lb = 0)
  stopifnot_int(target_states, lb = 0)
  stopifnot_int(states_if_pep_effective, lb = 0)
  stopifnot_int(states_if_pep_ineffective, lb = 0)

  # Labels are arbitrary, so no bounds. The length is only checked against
  # the model when the intervention first runs, since the number of agents
  # is not known here.
  if (length(agent_groups))
    stopifnot_int(agent_groups)

  InterventionMeaslesPEP_cpp(
    name,
    mmr_efficacy,
    ig_efficacy,
    ig_half_life_mean,
    ig_half_life_sd,
    mmr_willingness,
    ig_willingness,
    mmr_window,
    ig_window,
    target_states,
    states_if_pep_effective,
    states_if_pep_ineffective,
    as.integer(agent_groups)
  ) |>
    structure(class = c("epiworld_globalevent"))

}
