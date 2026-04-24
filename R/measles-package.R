#' measles: Measles Epidemiological Models
#'
#' A specialized collection of measles epidemiological models built on the
#' epiworldR framework. This package provides models for studying measles
#' transmission dynamics, including school settings with quarantine and
#' isolation policies, mixing models with population groups, and risk-based
#' quarantine strategies.
#'
#' @useDynLib measles, .registration = TRUE
#' @import epiworldR
#' @importFrom graphics boxplot plot
#' @keywords internal
"_PACKAGE"

#' Version of the measles C++ code
#'
#' Returns the version of the C++ library measles. The code
#' is hosted on GitHub at <https://github.com/UofUEpiBio/epiworld>,
#' and it is part of the epiworld C++ library.
#'
#' @return
#' A character string representing the version of the C++ library.
#'
#' @examples
#' measles_cpp_version()
#'
#' @export
#' @keywords internal
measles_cpp_version <- function() {
  measles_cpp_version_cpp()
}
