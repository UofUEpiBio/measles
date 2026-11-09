
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
#' @param target_stages Character vector. The stages of the agents offered PEP
#' (e.g., `c("Susceptible", "Latent", "Prodromal")`), among those of the
#' measles models: `"Susceptible"`, `"Latent"`, `"Prodromal"`, `"Rash"`,
#' `"Severe"` and `"Recovered"`.
#' @param target_statuses Character vector. The statuses of the agents offered
#' PEP (e.g., `"Quarantined"`), among `"Free"`, `"Quarantined"`, `"Isolated"`
#' and `"Hospitalized"`; `character(0)` offers it in any status.
#' @param ... Not used. The arguments `target_states`,
#' `states_if_pep_effective` and `states_if_pep_ineffective` of measles 0.4
#' are an error that says what replaced them.
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
#' 1. Agents in one of the `target_stages` and one of the `target_statuses`
#' are eligible for PEP if they are willing to accept it (based on
#' `mmr_willingness` and `ig_willingness`).
#'
#' 2. If the exposure started at most `mmr_window` days ago, they are offered
#' the MMR vaccine; otherwise, within `ig_window` days, IG.
#'
#' 3. An agent that carries the virus (e.g., Latent) clears it if the PEP
#' works (based on `mmr_efficacy` or `ig_efficacy`), through the model's
#' transition "PEP cleared" (to Recovered).
#'
#' 4. A dosed agent in quarantine is then released (back to Free) through the
#' model's transition "PEP release", whether or not the PEP worked.
#'
#' The stages and the statuses of the measles models, and the transitions
#' between them, are listed by [epiworldR::get_stages()],
#' [epiworldR::get_statuses()] and [epiworldR::get_hist_transitions()].
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
#' # Parameter values and sources
#'
#' The function has no defaults. The values used in `vignette("school")`,
#' with their sources, are listed in [measles_parameters()].
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
  target_stages,
  target_statuses,
  agent_groups = integer(0),
  ...
) {

  pep_defunct_args(...)

  stopifnot_character(name)
  stopifnot_double(mmr_efficacy, lb = 0, ub = 1)
  stopifnot_double(ig_efficacy, lb = 0, ub = 1)
  stopifnot_double(ig_half_life_mean, lb = 0)
  stopifnot_double(ig_half_life_sd, lb = 0)
  stopifnot_double(mmr_willingness, lb = 0, ub = 1)
  stopifnot_double(ig_willingness, lb = 0, ub = 1)
  stopifnot_double(mmr_window, lb = 0)
  target_stages <- measles_label_ids(target_stages, measles_stages, "stage")
  target_statuses <- measles_label_ids(
    target_statuses,
    measles_statuses,
    "status"
  )

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
    target_stages,
    target_statuses,
    as.integer(agent_groups)
  ) |>
    structure(class = c("epiworld_globalevent"))

}

# The stages and statuses of the measles models (ModelMeasles in epiworld)
measles_stages <- c(
  "Susceptible", "Latent", "Prodromal", "Rash", "Severe", "Recovered"
)
measles_statuses <- c("Free", "Quarantined", "Isolated", "Hospitalized")

# The ids (0-based) of stages or statuses named by their labels
measles_label_ids <- function(x, labels, what) {

  if (!is.character(x) || anyNA(x))
    stop(
      sprintf("The %s are named by their labels (", paste0(what, "es")),
      paste0("\"", labels, "\"", collapse = ", "), ").",
      call. = FALSE
    )

  ids <- match(x, labels)
  if (anyNA(ids))
    stop(
      sprintf("The measles models have no %s ", what),
      paste0("\"", x[is.na(ids)], "\"", collapse = ", "), "; they have ",
      paste0("\"", labels, "\"", collapse = ", "), ".",
      call. = FALSE
    )

  as.integer(ids - 1L)

}

# The arguments that measles 0.4 took, which the model's transitions replaced
pep_defunct_args <- function(...) {

  old <- intersect(
    names(list(...)),
    c("target_states", "states_if_pep_effective", "states_if_pep_ineffective")
  )

  if (length(old))
    stop(
      "InterventionMeaslesPEP() no longer takes ",
      paste0("-", old, "-", collapse = ", "), " (defunct as of measles ",
      "0.5.0). The states are now a stage and a status: give the agents ",
      "offered PEP by their stages (-target_stages-, e.g., c(\"Susceptible\", ",
      "\"Latent\", \"Prodromal\")) and statuses (-target_statuses-, e.g., ",
      "\"Quarantined\"). Where they go is the model's: \"PEP cleared\" (to ",
      "Recovered) and \"PEP release\" (from Quarantined to Free).",
      call. = FALSE
    )

  if (...length())
    stop("Unused arguments: ", paste(names(list(...)), collapse = ", "), ".",
      call. = FALSE
    )

  invisible()

}
