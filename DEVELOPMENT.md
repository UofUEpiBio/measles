# Developing `measles`

## Versioning

We use [Semantic Versioning](https://semver.org): MAJOR.MINOR.PATCH.

## Submitting to CRAN

When submitting to CRAN, the package must be built with the latest development version of R.
As our GHA for `R CMD check` already builds the package on `r-devel`, we upload the result of this build process.
The package is found by going to the `R-CMD-check-final` GitHub Action run, selecting `ubuntu-latest (devel)` then `Run actions/upload-artifact@v4`.
Clicking the "Artifact download URL" will download a zip archive titled `measles-built-package-ubuntu-latest-devel.zip` which contains the `measles_X.X.X.X.tar.gz` tarbell file we need to upload to CRAN.
Simply unzip the `measles-built-package-ubuntu-latest-devel.zip` and upload the tarbell.

**NOTE:** On macOS, simply double-clicking the `measles-built-package-ubuntu-latest-devel.zip` file will automatically unzip both the `.zip` and the `.tar.gz` file.
We found it best to us the `unzip` command in the command line to unzip just the `.zip` file and leave the `.tar.gz` file ready for upload.
