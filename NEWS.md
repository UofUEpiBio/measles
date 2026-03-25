# measles 0.2.0

## Internal changes

* Added `playground/shortcreek.cpp`, a pure C++ port of the Short Creek mixing
  model vignette (`vignettes/short-creek.qmd`). This standalone program
  replicates the model setup and `run_multiple()` call using only the epiworld
  C++ library and the standard library. A `playground/Makefile` is included for
  building the program.

## User visible changes

* The vaccination efficacy has been modified to reflect a probability (the original intent) instead of a rate. Previous versions were resulting in a higher than expected vaccinated individuals becoming infected (update from epiworldR 0.13.0.0).

* Improved documentation regarding vaccination rates and probabilities across models.


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
