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
