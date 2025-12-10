# measles (development version)

## Internal Changes

* Removed unused functions from `arg-checks.R` to reduce code bloat and improve maintainability. The following functions were removed as they were not used anywhere in the package: `stopifnot_string`, `stopifnot_bool`, `stopifnot_numvector`, `stopifnot_stringvector`, `stopifnot_model`, `stopifnot_agent`, `stopifnot_entity`, `stopifnot_entity_distfun`, `stopifnot_lfmcmc`, `stopifnot_tool`, `stopifnot_tfun`, `stopifnot_tool_distfun`, `stopifnot_virus`, `stopifnot_vfun`, and `stopifnot_virus_distfun`.

# measles 0.1.0

This is the first release of the measles R package, a spin-off of the epiworldR package, focused on modeling measles transmission dynamics.

## New Features

* Added `get_contact_matrix()` and `set_contact_matrix()` functions to retrieve and modify the contact matrix for mixing models. These functions are available for:
  - `ModelMeaslesMixing`
  - `ModelMeaslesMixingRiskQuarantine`

  Other mixing models in epiworld will have these methods available in the near future.
