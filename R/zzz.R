.onAttach <- function(libname, pkgname) {
  packageStartupMessage(
    "Using measles in your research? Please cite it: citation(\"measles\")"
  )
}
