# measles 0.5.0-0 (development)

Tracks epiworldR 1.0.0 (its `v1-layers` branch), where contacts come from
contact layers.

* **Breaking: natural histories** (epiworld NH-1 to NH-4, ported in
  epiworldR 1.0.0). Each agent has a **stage** of the disease (Susceptible,
  Latent, Prodromal, Rash, Severe, Recovered; `get_stages(model)`) and a
  **status**, where it is (Free, Quarantined, Isolated, Hospitalized;
  `get_statuses(model)`), instead of one combined state
  ("Quarantined Latent", "Detected Hospitalized", ...). The outputs keep the
  two apart: `get_hist_total()`, `get_hist_tool()` and the
  `run_multiple_get_results()` tables have `status` and `stage` columns, the
  transitions have `status_from`, `stage_from`, `status_to` and `stage_to`
  (`from_status`, `from_stage`, ... in `make_saver("transition")`), and `get_hist_transitions()` counts the declared transitions
  ("Quarantined", "Isolated", "Admitted", "PEP cleared", ...) by day. A
  hospitalized case is one that went from Rash to Severe (and from any status
  to Hospitalized). `initial_states()` is defunct in epiworldR; agents start
  in a stage without the virus with `set_initial(model, assign_shares(c(
  Recovered = 0.1)))`.

* **Breaking:** `InterventionMeaslesPEP()` takes the stages and statuses of
  the agents offered PEP, by their labels (`target_stages = c("Susceptible",
  "Latent", "Prodromal")`, `target_statuses = "Quarantined"`), instead of
  `target_states`, `states_if_pep_effective` and `states_if_pep_ineffective`
  (now an error saying so). Where a dosed agent goes is the model's: the
  virus is cleared through the transition "PEP cleared" (to Recovered) if the
  PEP works, and the agent is released from quarantine through "PEP release".

* The models are built by epiworld's model registry
  (`measles::register_models()`), which checks the values of the arguments;
  the constructors keep their arguments.

* Placements replace the distribution functions: vaccination by group is
  `assign_tool(model, 0, assign_group_shares("mixing", rates))` (see the Short
  Creek vignette) instead of `distribute_tool_to_entities()`, and
  `grouping_random(sizes)` is `assign_counts(sizes)` (both defunct in
  epiworldR).

* `{measles}` requires `{epiworldR}` (>= 1.0.0), and its headers come from
  epiworld's `v1-layers` (`inst/include/VERSIONS` records the commit).

* **Breaking:** `ModelMeaslesMixing()` and
  `ModelMeaslesMixingRiskQuarantine()` take their groups and contact matrix
  from a mixing layer, which you add instead of entities, and lose their
  `contact_matrix` argument:

  ```r
  model <- ModelMeaslesMixing(n = 9000, prevalence = 1 / 9000, prop_vaccinated = .95)
  add_layer(
    model,
    layer_mixing(
      "mixing",
      groups         = assign_counts(c(3000, 3000, 3000)),
      contact_matrix = cmatrix
    )
  )
  ```

  `assign_counts()` draws what `entity(name, size, as_proportion = FALSE)`
  did; fixed groups (e.g., `rep(0:2, sizes)`, what
  `add_entities_from_dataframe()` did) go in `groups` as well. Running a mixing
  model without its layer, or with other layers, is an error. The contacts are
  logged in the layer, which the quarantine process reads; since the layer
  holds the contact matrix, epiworldR's `get_contact_matrix()` and
  `set_contact_matrix()` on `get_layer(model, "mixing")` read and change it,
  and `set_contact_rate()` on the layer scales it by a model parameter.

* `ModelMeaslesSchool()` does not change; it now logs its contacts in its own
  layer, `"school"`.

* The changes of measles 0.4.1-0 (lognormal stage durations,
  `hospitalization_rate()`, the default `hospitalization_rate` of 0.035) are
  part of this version, with the mixing models built on their mixing layer.

* The headers come from epiworld 07ed7a0d, where entities and the model's
  contact tracer are gone (UofUEpiBio/epiworld#349): the post-exposure
  prophylaxis intervention reads the contact logs of the model's traced
  layers. Results do not change; `{measles}` bound neither.

* `get_transmissions()`'s `layer` column stays `-1` for the measles models:
  their own samplers do not record the layer of a contact.

* In `measles_parameters()`, the contact matrix is no longer an argument of
  the mixing models (it is the mixing layer's).

* `ModelMeaslesMixing()`: detected initial cases now leave isolation once the
  isolation period is over (before, those who recovered in isolation stayed in
  "Isolated Recovered" for good). Results for a given seed change when that
  happens.

# measles 0.4.1-0

## User visible changes

* **Stage durations are no longer geometric.** The incubation (latent), prodromal, and rash stages of `ModelMeaslesSchool()`, `ModelMeaslesMixing()`, and `ModelMeaslesMixingRiskQuarantine()` now last a lognormal number of days, drawn when the agent enters the stage, with the given mean (`incubation_period`, `prodromal_period`, `rash_period`) and the new arguments `incubation_period_sd` (default 2.5), `prodromal_period_sd` (1.7), and `rash_period_sd` (1.0). A standard deviation of zero gives a fixed duration. Previously, each stage was left with a daily probability of one over its mean, so long stays were too common: with a mean incubation of 12 days, 16% of cases were still latent after 21 days (0.2% now). Quarantine and isolation do not change a stage: an agent moved from Latent to Quarantined Latent keeps the day its latent period ends. The default standard deviations come from Lessler et al. (2009) and the 1861 Hagelloch outbreak; see `vignette("parameters")` and `measles_parameters()`. Simulation results change.

* The new function `hospitalization_rate()` finds the daily hospitalization rate that gives a target probability of hospitalization, for the drawn rash period (e.g., `hospitalization_rate(0.1)` is 0.0347).

* Each day with rash, an agent is now hospitalized with probability `hospitalization_rate`, and otherwise recovers when its rash period ends, so the probability of hospitalization is `1 - E[(1 - h)^D]`. **The default `hospitalization_rate` is now 0.035** (it was 0.2), which gives about 10% of cases hospitalized, as in recent data (CDC, 2026; Jones et al. 2026 in Utah). The previous default gave 37.5%. The documentation, the parameter table, and the vignettes show the new conversion between rate and probability.

* `{measles}` now requires `{epiworldR}` (>= 0.19.0), which is distributed through R-universe (<https://uofuepibio.r-universe.dev>). The repository is listed under `Additional_repositories` in `DESCRIPTION`, so `install.packages("measles", repos = c("https://uofuepibio.r-universe.dev", "https://cloud.r-project.org"))` resolves it. The startup check now asks for `{epiworldR}` 0.19.0 as well.

* The column `vacc_rate` of the `short_creek` dataset is now the vaccination coverage (share vaccinated), as documented. Previously it was the share immune (coverage times a vaccine efficacy of 0.97, or 0.93 under age 5), so models that also set `vax_efficacy` applied the efficacy twice. The overall coverage is 51.9% (the share immune was 50.3%). The contact matrix `short_creek_matrix` is unchanged.

* The new function `measles_parameters()` returns the canonical table of model parameters, with their defaults, units, literature ranges, and sources. The table is stored in `inst/extdata/measles_parameters.csv`, and the new vignette `vignette("parameters")` discusses it, including the R0 calibration and the conversion between hospitalization rate and probability. The table prints each parameter with its argument ("Parameter (argument)") each default with its units ("Default (units)"), and each source with its notes ("Source (and notes)", with each note after "Note:"); `format(measles_parameters(), markdown = TRUE)` gives the same layout for Markdown tables, as in the vignette. The vignette's references include the Utah DHHS Measles Disease Plan. No default values changed.

* Parameters chosen without a published source, such as the default hospitalization rate (0.2), the tiered quarantine lengths of `ModelMeaslesMixingRiskQuarantine()`, and the willingness and contact-tracing parameters, are now labeled simply as assumptions in `measles_parameters()`, the vignette, and the documentation.

* Fixed the documented default vaccine efficacy of `ModelMeaslesMixing()` and `ModelMeaslesMixingRiskQuarantine()` (0.97, not 0.99), and clarified that `hospitalization_rate` is a daily rate, not a probability. The model constructors now link to `measles_parameters()`.

* The examples of `ModelMeaslesMixing()` and `ModelMeaslesMixingRiskQuarantine()` now use the package defaults for the disease periods, hospitalization, and isolation, instead of values that contradicted them.

* The documentation of `ModelMeaslesMixing()` now flags `vax_reduction_recovery_rate` as inactive: the model registers it as "(IGNORED) Vax improved recovery", and it has no effect on the simulation.

## Bug fixes

* In the mixing models, the probability of contacting each infectious agent of a group (contacts per day over the group's agents available for contact) could exceed 1 when most of a small group was quarantined or isolated. It is now capped at 1. Before, `std::binomial_distribution` received an invalid probability, which aborted builds with `_GLIBCXX_ASSERTIONS` (on by default in GCC 15 unoptimized builds, such as the coverage job) and was undefined behavior otherwise.

* `ModelMeaslesSchool()` no longer draws a number of contacts when nobody is infectious (an invalid Poisson draw with mean 0 under the same builds). Results do not change.

* Through `{epiworldR}` 0.19.0, `run_multiple()` now runs every replicate when OpenMP grants fewer threads than requested (e.g., under `OMP_THREAD_LIMIT`). Previously the replicates assigned to the missing threads were silently skipped while still being counted.

## Internal changes

* Synced the measles C++ headers (`inst/include/measles`) with `UofUEpiBio/epiworld` at d492315 (UofUEpiBio/epiworld#348, based on master at e15ea2e), which adds the stage durations (`stages.hpp`) and includes UofUEpiBio/epiworld#338 (initial cases of `ModelMeaslesMixing()` leave isolation).

* Added `inst/tinytest/test-stage-durations.R`, which checks fixed and lognormal stage durations end to end.

* `inst/tinytest/test-measlesmixingriskquarantine-multiple.R` compares quarantine strategies over 400 simulations instead of 50, so the comparisons do not depend on the platform's random stream.

* Added `data-raw/stage_durations.R`, which derives the default standard deviations of the stage durations (including the fit to the Hagelloch outbreak) and the default hospitalization rate. Its data, the days from prodrome to rash onset of the 188 Hagelloch cases extracted from the `surveillance` package, are in `data-raw/hagelloch_prodromal_days.csv`, and its results in `data-raw/stage_durations.csv`. The parameter table points to it.

* Added a test that checks `inst/extdata/measles_parameters.csv` against the arguments and defaults of the model constructors, so the parameter table cannot drift from the code.

* Synced the measles C++ headers (`inst/include/measles`) with `UofUEpiBio/epiworld` at commit 87b2f98. The models now look up parameters with `EPI_PAR()`/`ParamRef` (faster, cached lookups), and the school and mixing models record contacts for contact tracing through epiworld's post-sampling callback (`make_contact_tracing_post_sampling()`) instead of calling `add_contact()` inline. The contacts recorded (and the day they are recorded) are the same as before.

* Added a test (`inst/tinytest/test-school-contact-tracing.R`) checking that the contacts sampled in `ModelMeaslesSchool()` are still recorded for contact tracing and drive `InterventionMeaslesPEP()`: PEP is offered after a case with recorded contacts is identified, and not offered when the case had no contacts.

# measles 0.4.0-0

## User visible changes

* The function `InterventionMeaslesPEP()` implements post-exposure prophylaxis featuring both MMR and IG. The process is highly configurable and can be attached to the `ModelMeaslesSchool()`. Not available yet for other models.

* Fixed the PEP timelines. `mmr_window`/`ig_window` are now measured from the exposure to the day the case is identified, i.e. whether there is still time to intervene. The reference date is the *first* day the school encountered the index case on or after its infectious-onset date (rash onset minus the prodromal period); contact tracing is used only to date that first encounter, so if the contact rate is zeroed out on some days (e.g. weekends, via a global event) the first day actually in session anchors the window. When several cases are identified on the same day, the earliest of those first encounters applies. Previously the windows were compared against the index case's infectious-onset date and gated on the specific day a given classmate met the index, so realistic windows (e.g. `mmr_window = 3`) did not behave as intended.

* PEP is now offered to the whole school rather than only to the index case's recorded contacts, reflecting that public health treats the exposed group as exposed rather than tracing individual contacts. Agents already holding a PEP tool are not dosed again (IG still wanes, after which they become eligible once more). Note this makes PEP considerably more widely administered than in previous versions, and outbreak sizes correspondingly smaller.

* `InterventionMeaslesPEP()` gains an optional `agent_groups` argument for circumscribing that exposed group. Offering PEP to the entire population is appropriate for a single classroom but misleading when the population is really a set of separate communities. Supplying one group label per agent (e.g. `agent_groups = rep(1:3, each = 20)`) restricts the offer to the group(s) of the identified case(s), and dates each group's window from its own exposure, so a case identified in one classroom no longer shortens the window available to another. The default, `integer(0)`, keeps the whole-population behavior.

* Fixed PEP being re-administered every day after a case was identified. The set of triggering cases was only refreshed when a new case was detected, so on quiet days the intervention kept responding to an old detection.

* The models `ModelMeaslesMixing()` and `ModelMeaslesMixingRiskQuarantine()` no longer use `contact_rate`; instead, their `contact_matrix` stores the expected number of contacts between groups. Calibration can now be done with the new function `calibrate_mixing_model()`.

* Updated the documentation, examples, and contact-matrix helpers for the mixing models so they consistently treat `contact_matrix` as the full contact-rate matrix.

* Aligned the package documentation and examples with the updated measles state names from `{epiworldR}`, replacing `Exposed`/`Quarantined Exposed` with `Latent`/`Quarantined Latent` where those names refer to model states.

* Changed the default vaccine efficacy of Measles from 99% to 97%.

* The contact tracing window parameter in `ModelsMeaslesMixing()` and `ModelMeaslesMixingRiskQuarantine()` was capturing agents that may have been in contact with infected cases way past the window. No important regressions observed from this change.

* The `ModelMeaslesMixing()` now allows agents with Rash to be infectious. Previously, we assumed that Rash agents would stay home. We now relaxed this assumption to allow agents to have a different contact rate.

* The new function `make_cmat_symmetric()` allows symmetrizing a contact matrix based on the population size (adapted from `socialmixr::symmetrise()`).

* `get_contact_matrix()` and `set_contact_matrix()` are now provided by `{epiworldR}` (>= 0.15.1) and work directly on the measles mixing models. The package's own copies were removed so they no longer mask the `{epiworldR}` versions.

## Internal changes

* Updated package citation metadata to include all people listed in `Authors@R`.

* Added repository citation metadata for GitHub and other CFF consumers.

* Added pkgdown author metadata linking George Vega Yon's website.

* The Measles models were removed from `{epiworldR}`. This streamlines the development process. So, if we need to update Measles related models, we only need to update the `{measles}` R package, not `{epiworldR}` and `{measles}`.

* The `ModelMeaslesMixing` includes parameter validation on the C++ side.

* The latest version of `epiworld` optimizes the binomial sampler, switching to a Poisson sampler based on Le Cam's inequality.


# measles 0.2.0

## User visible changes

* The vaccination efficacy has been modified to reflect a probability (the original intent) instead of a rate. Previous versions were resulting in a higher than expected vaccinated individuals becoming infected (update from epiworldR 0.13.0.0).

* Improved documentation regarding vaccination rates and probabilities across models.

## Internal changes

* This version uses the latest version of `epiworld` (0.14.0), which introduced several important changes. You can read more about the changes [here](https://github.com/UofUEpiBio/epiworld/pull/189) (the corresponding `epiworldR` PR is [here](https://github.com/UofUEpiBio/epiworldR/pull/172).).


# measles 0.1.1

## Internal changes

* Removed the `configure` script infrastructure (`configure.ac`, `configure`,
  `cleanup`, `src/Makevars.in`) in favor of a static `src/Makevars` that uses
  R's own `$(SHLIB_OPENMP_CXXFLAGS)` for OpenMP support. This addresses
  CRAN policy compliance by removing unnecessary C++11 compiler testing and
  custom OpenMP detection.

* Added `CXX_STD = CXX17` to `src/Makevars` and `src/Makevars.win`, and
  `SystemRequirements: C++17` to `DESCRIPTION`, as required by the epiworld
  C++ headers (`std::string_view`, `if constexpr`).

# measles 0.1.0

This is the first release of the measles R package, a spin-off of the epiworldR package, focused on modeling measles transmission dynamics.

## New Features

* Added `get_contact_matrix()` and `set_contact_matrix()` functions to retrieve and modify the contact matrix for mixing models. These functions are available for:
  - `ModelMeaslesMixing`
  - `ModelMeaslesMixingRiskQuarantine`

  Other mixing models in epiworld will have these methods available in the near future.
