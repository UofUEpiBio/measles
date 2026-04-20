# measles 0.2.0.9000

## User visible changes

* The function `InterventionMeaslesPEP()` implements post-exposure prophylaxis featuring both MMR and IG. The process is highly configurable and can be attached to the `ModelMeaslesSchool()`. Not available yet for other models.

* The models `ModelMeaslesMixing()` and `ModelMeaslesMixingRiskQuarantine()` no longer use `contact_rate`; instead, their `contact_matrix` stores the expected number of contacts between groups.

* Updated the documentation, examples, and contact-matrix helpers for the mixing models so they consistently treat `contact_matrix` as the full contact-rate matrix.

* Aligned the package documentation and examples with the updated measles state names from `{epiworldR}`, replacing `Exposed`/`Quarantined Exposed` with `Latent`/`Quarantined Latent` where those names refer to model states.

## Internal changes

* The Measles models were removed from `{epiworldR}`. This to streamline the development process. So, if we need to update Measles related models, we only need to update the `{measles}` R package, not `{epiworldR}` and `{measles}`.


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
