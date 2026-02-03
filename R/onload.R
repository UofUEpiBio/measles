#' @noRd
#' @importFrom utils packageVersion
check_epiworldr_version <- function() {

  ev <- utils::packageVersion("epiworldR")
  required <- package_version("0.11.2.0")

  if (ev < required) {
    packageStartupMessage(
      "The installed version of the epiworldR R package (", ev,
      ") is not the latest available. Since epiworldR is actively ",
      "used in public health responses, the package is ",
      "continually updated. Please install version ", required, "."
    )
  }

}
.onLoad <- function(libname, pkgname) {
  check_epiworldr_version()
}
