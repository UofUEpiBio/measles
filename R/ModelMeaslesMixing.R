#' Measles model with mixing
#'
#' `ModelMeaslesMixing` creates a measles epidemiological model with mixing
#' between different population groups. The model includes vaccination,
#' quarantine, isolation, and contact tracing mechanisms.
#'
#' @param n Number of individuals in the population.
#' @param prevalence Double. Initial proportion of individuals with the virus.
#' @param contact_matrix A numeric square matrix with the expected number of
#' contacts per time step between population groups.
#' @param vax_reduction_recovery_rate Double. Vaccine reduction in recovery
#' rate (default: 0.5). **Not active:** the model registers it as
#' "(IGNORED) Vax improved recovery", and it has no effect on the simulation.
#' Future versions may deprecate it.
#' @param transmission_rate Numeric scalar between 0 and 1. Probability of
#' transmission (default: 0.9).
#' @param prop_vaccinated Double. Proportion of population that is vaccinated.
#' @param vax_efficacy Double. Vaccine efficacy rate (default: 0.97).
#' @param quarantine_period Integer. Number of days for quarantine
#' (default: 21).
#' @param quarantine_willingness Double. Proportion of agents willing to
#' quarantine (default: 1).
#' @param isolation_willingness Double. Proportion of agents willing to isolate
#' (default: 1).
#' @param isolation_period Integer. Number of days for isolation (default: 4).
#' @param incubation_period Double. Mean duration of the incubation period in
#' days (default: 12).
#' @param prodromal_period Double. Mean duration of the prodromal period in
#' days (default: 4).
#' @param rash_period Double. Mean duration of the rash period in days
#' (default: 3).
#' @param hospitalization_rate Double. Daily rate of hospitalization, not a
#' probability (default: 0.035, about 10% of cases hospitalized). See the
#' Hospitalization Probability section.
#' @param hospitalization_period Double. Period of hospitalization (default: 7).
#' @param days_undetected Double. Number of days an infection goes undetected
#' (default: 2).
#' @param contact_tracing_success_rate Double. Probability of successful
#' contact tracing (default: 1.0).
#' @param contact_tracing_days_window Integer. Number of days before rash onset
#' that will be considered for contact tracing (default: 4).
#' @param rash_reduction_contact_rate Double. Reduction in contact rate during
#' rash period (default: 1.0, full reduction). (see details)
#' @param incubation_period_sd Double. Standard deviation of the incubation
#' period in days (default: 2.5). See the Stage Durations section.
#' @param prodromal_period_sd Double. Standard deviation of the prodromal
#' period in days (default: 1.7).
#' @param rash_period_sd Double. Standard deviation of the rash period in days
#' (default: 1.0).
#' @export
#' @family Models
#' @family measles models
#' @concept measles-models
#' @details
#' The `contact_matrix` is a square matrix of contact rates between entities.
#' Entry `[i, j]` gives the expected number of contacts that an agent in entity
#' `i` has with agents in entity `j` during a time step. The matrix should have
#' one row and one column per entity in the model.
#'
#' The model includes three distinct phases of measles infection: incubation,
#' prodromal, and rash periods. Vaccination provides protection against
#' infection.
#'
#' The [initial_states] function allows the user to set the initial state of the
#' model. In particular, the user can specify how many of the non-infected
#' agents have been removed at the beginning of the simulation.
#'
#' @section Contact Rate Reduction During Rash Period:
#' The default behavior of the model is that agents in the rash period
#' are self-isolated. Nonetheless, since version 0.3.2-0, the user can
#' set the `rash_reduction_contact_rate` parameter to a value between 0 and 1 to
#' allow agents with Rash to still contact other agents, albeit at a reduced
#' rate. For example, if the user sets `rash_reduction_contact_rate` to 0.8,
#' agents in the rash period will have 20% of the contact rates specified in
#' the `contact_matrix` instead of 0%.
#'
#' The basic reproduction number (R0) of the model can be computed as
#'
#' \deqn{
#' \mathcal{R}_0 = p_t c (D_p + (1-r_r) D_r)
#' }{
#' R0 = p_t c (D_p + (1-r_r) D_r)
#' }
#'
#' Where \eqn{p_t} is the `transmission_rate`, \eqn{c} is the average number of
#' contacts per time step (given by the `contact_matrix`), \eqn{D_p} is
#' the mean duration of the prodromal period, \eqn{D_r} is the mean number of
#' days with rash before recovery or hospitalization (shorter than the rash
#' period when hospitalization is likely), and \eqn{r_r} is the
#' `rash_reduction_contact_rate`. Therefore, when
#' calibrating the model, the effective infectious period should be considered
#' as the sum of the prodromal period and the rash period scaled by
#' `(1 - rash_reduction_contact_rate)`.
#'
#' @section Stage Durations:
#' The latent (incubation), prodromal, and rash stages last a number of days
#' drawn when the agent enters the stage, from a lognormal distribution with
#' the stage's mean (`incubation_period`, `prodromal_period`, `rash_period`)
#' and standard deviation (`incubation_period_sd`, `prodromal_period_sd`,
#' `rash_period_sd`), both in days. The draw is rounded to whole days, with a
#' minimum of one. A standard deviation of zero gives a fixed duration.
#'
#' Before version 0.4.1-0, every stage was left with a daily probability
#' (1 / mean), so its duration was geometric (memoryless). Measles stage
#' durations are not: they are concentrated around their mean, and the
#' geometric puts too much weight on short and long stays. With a mean
#' incubation period of 12 days, 16% of agents were still latent after 21
#' days, longer than a quarantine; with the lognormal default, 0.2% are.
#'
#' The evidence for each stage (see [measles_parameters()] and
#' `vignette("parameters")`):
#'
#' - **Incubation:** incubation periods of infectious diseases are well
#'   described by lognormal distributions (Sartwell, 1950), and the pooled
#'   measles estimate of Lessler et al. (2009) is a lognormal (median 12.5
#'   days, dispersion 1.23), which gives the default standard deviation.
#' - **Prodromal:** in the 1861 Hagelloch outbreak (188 cases), the days from
#'   prodrome to rash onset are fitted equally well by a lognormal and a gamma
#'   (mean 4.0, sd 1.7), and much worse by an exponential (geometric). No
#'   published study fits a distribution to this period, as far as we know.
#' - **Rash:** no data describe the distribution of the infectious part of
#'   the rash; the lognormal and its standard deviation are assumptions.
#'
#' Compartmental models of measles describe the latent and infectious periods
#' with gamma (Erlang) distributions instead, for the same reason (Conlan et
#' al., 2010). With the means and standard deviations used here, a lognormal
#' and a gamma differ little.
#'
#' Moving to quarantine or isolation does not change the stage: an agent
#' moved from Latent to Quarantined Latent keeps the day its latent period
#' ends, and so does an agent moved from Rash to Isolated.
#'
#' @section Hospitalization Probability:
#' Instead of hospitalization probability, the model uses hospitalization rate:
#' each day with rash (in the Rash or Isolated states), an agent is
#' hospitalized with probability \eqn{h} (`hospitalization_rate`); otherwise,
#' it recovers when its rash period \eqn{D} ends. The probability of
#' hospitalization is
#'
#' \deqn{
#' P(\text{hospitalization}) = 1 - E\left[(1 - h)^D\right],
#' }{
#' P(hospitalization) = 1 - E[(1 - h)^D],
#' }
#'
#' which, for a fixed rash period (`rash_period_sd = 0`), is
#' \eqn{1 - (1 - h)^D}. To match a desired hospitalization probability
#' `p_hosp`, use [hospitalization_rate()], which solves the equation for the
#' drawn rash period:
#'
#' ```r
#' h_rate <- hospitalization_rate(p_hosp, rash_period, rash_period_sd)
#' ```
#'
#' @section Parameter values and sources:
#' The defaults and their literature sources are listed in [measles_parameters()]. See
#' `vignette("parameters", package = "measles")` for a discussion.
#'
#' @section Model diagram:
#' ![](measlesmixing.png "Measles Mixing Diagram")
#' @returns
#' - The `ModelMeaslesMixing` function returns a model of classes
#' [epiworld_model] and [epiworld_measlesmixing].
#' @aliases epiworld_measlesmixing
#'
#' @examples
#'
#' # Start off creating three entities.
#' # Individuals will be distributed randomly between the three.
#' e1 <- entity("Population 1", 3e3, as_proportion = FALSE)
#' e2 <- entity("Population 2", 3e3, as_proportion = FALSE)
#' e3 <- entity("Population 3", 3e3, as_proportion = FALSE)
#'
#' # Contact matrix including within- and between-group contact rates
#' cmatrix <- (c(
#'   c(0.9, 0.05, 0.05),
#'   c(0.1, 0.8, 0.1),
#'   c(0.1, 0.2, 0.7)
#' ) * 15) |> matrix(byrow = TRUE, nrow = 3)
#'
#' N <- 9e3
#'
#' # Disease periods, vaccine efficacy, hospitalization, and isolation use the
#' # package defaults (see measles_parameters()). The willingness and contact
#' # tracing values are illustrative and lower than the defaults.
#' measles_model <- ModelMeaslesMixing(
#'   n                        = N,
#'   prevalence               = 1 / N,
#'   contact_matrix           = cmatrix,
#'   prop_vaccinated          = 0.95,
#'   quarantine_willingness   = 0.9,
#'   isolation_willingness    = 0.9,
#'   contact_tracing_success_rate = 0.8
#' )
#'
#' # Adding the entities to the model
#' measles_model |>
#'   add_entity(e1) |>
#'   add_entity(e2) |>
#'   add_entity(e3)
#'
#' set.seed(331)
#' run(measles_model, ndays = 100)
#' summary(measles_model)
#'
#' @seealso epiworld-methods
ModelMeaslesMixing <- function(
  n,
  prevalence,
  contact_matrix,
  vax_reduction_recovery_rate = .5,
  transmission_rate = .9,
  prop_vaccinated,
  vax_efficacy = .97,
  quarantine_period = 21,
  quarantine_willingness = 1,
  isolation_willingness = 1,
  isolation_period = 4,
  incubation_period = 12,
  prodromal_period = 4,
  rash_period = 3,
  hospitalization_rate = 0.035,
  hospitalization_period = 7,
  days_undetected = 2,
  contact_tracing_success_rate = 1.0,
  contact_tracing_days_window = 4,
  rash_reduction_contact_rate = 1.0,
  incubation_period_sd = 2.5,
  prodromal_period_sd = 1.7,
  rash_period_sd = 1.0
) {
  # Check input parameters
  stopifnot_int(n)
  stopifnot_double(prevalence)
  stopifnot_double(transmission_rate)
  stopifnot_double(vax_efficacy, lb = 0, ub = 1)
  stopifnot_double(vax_reduction_recovery_rate)
  stopifnot_double(incubation_period)
  stopifnot_double(prodromal_period)
  stopifnot_double(rash_period)
  stopifany_na(contact_matrix)
  stopifnot_double(hospitalization_rate)
  stopifnot_double(hospitalization_period)
  stopifnot_double(days_undetected)
  stopifnot_int(quarantine_period)
  stopifnot_double(quarantine_willingness, lb = 0, ub = 1)
  stopifnot_double(isolation_willingness, lb = 0, ub = 1)
  stopifnot_int(isolation_period)
  stopifnot_double(prop_vaccinated, lb = 0, ub = 1)
  stopifnot_double(contact_tracing_success_rate, lb = 0, ub = 1)
  stopifnot_int(contact_tracing_days_window, lb = 0)
  stopifnot_double(rash_reduction_contact_rate, lb = 0, ub = 1)
  stopifnot_double(incubation_period_sd, lb = 0)
  stopifnot_double(prodromal_period_sd, lb = 0)
  stopifnot_double(rash_period_sd, lb = 0)

  structure(
    ModelMeaslesMixing_cpp(
      n = n,
      prevalence = prevalence,
      transmission_rate = transmission_rate,
      vax_efficacy = vax_efficacy,
      vax_reduction_recovery_rate = vax_reduction_recovery_rate,
      incubation_period = incubation_period,
      prodromal_period = prodromal_period,
      rash_period = rash_period,
      contact_matrix = as.vector(contact_matrix),
      hospitalization_rate = hospitalization_rate,
      hospitalization_period = hospitalization_period,
      days_undetected = days_undetected,
      quarantine_period = quarantine_period,
      quarantine_willingness = quarantine_willingness,
      isolation_willingness = isolation_willingness,
      isolation_period = isolation_period,
      prop_vaccinated = prop_vaccinated,
      contact_tracing_success_rate = contact_tracing_success_rate,
      contact_tracing_days_window = contact_tracing_days_window,
      rash_reduction_contact_rate = rash_reduction_contact_rate,
      incubation_period_sd = incubation_period_sd,
      prodromal_period_sd = prodromal_period_sd,
      rash_period_sd = rash_period_sd
    ),
    class = c("epiworld_measlesmixing", "epiworld_model")
  )

}
