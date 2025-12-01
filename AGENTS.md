## Overview

- This repository hosts an R package that depends on the `epiworldR` R package for running epidemiological ABMs.
- The package uses the following coding standards:
  - Tests are written using `tinytest`.
  - Documentation is generated with `roxygen2`.
  - We use snake case for naming variables and functions. The only exception is the function names that are exported from C++ (see the `src/` folder), which use camel case. Thus, to preserve consistency, we use camel case when calling these functions from R.
- We like to avoid adding unnecessary dependencies (keep them minimal). Unless strictly necessary, we do not add new packages.
- The target audience of the package are epidemiologists both researchers and public health practitioners, with varying levels of programming skills. Thus, we aim to keep the code as simple and readable as possible.

## How to make changes to the package

- Changes should be reflected in the NEWS.md file, usually with the following sections: "User visible changes", "Bug fixes", and "Internal changes".
- We use `devtools::check()` to check the package for common issues before committing changes.
- We use `devtools::document()` to generate documentation after making changes to the code. WE AVOID MANUALLY EDITING THE DOCUMENTATION FILES.
- We use `devtools::test()` to run the tests after making changes to the code
