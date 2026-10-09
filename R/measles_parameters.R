#' Measles model parameters and literature references
#'
#' Returns the canonical table of parameters used by the measles models,
#' including their package defaults, units, literature ranges, and sources.
#' This table is the single source of truth that other projects using the
#' package point to.
#'
#' @details
#' The table is stored in `inst/extdata/measles_parameters.csv` and has one row
#' per parameter. Its columns are:
#'
#' - `parameter`: Name of the parameter in the C++ model (as shown by
#'   `summary()`). Rows in parentheses are model inputs without a C++
#'   parameter name, and rows without an `r_argument` are derived quantities
#'   (e.g., R0).
#' - `r_argument`: Name of the R argument.
#' - `models`: Functions that take the argument, separated by `;`.
#' - `default`: Package default, as R code. For [InterventionMeaslesPEP()],
#'   which has no defaults, it is the value used in `vignette("school")`.
#' - `units`, `type`: Units and type of the parameter (`probability`,
#'   `rate`, `days`, or `count`).
#' - `lit_low`, `lit_high`: Range reported in the cited source, if any.
#' - `description`, `citation`, `doi_or_url`, `notes`: What the parameter
#'   is, where its value comes from, and further notes.
#'
#' Hospitalization in the models is a daily rate, not a probability. The
#' probability of hospitalization is `h / (h + 1 / rash_period)`. See
#' `vignette("parameters", package = "measles")` for more details.
#'
#' @param model Optional character scalar with the name of a model function
#' (e.g., `"ModelMeaslesSchool"`). If specified, only the rows of parameters
#' used by that model are returned.
#' @returns A data frame with one row per parameter.
#' @examples
#' params <- measles_parameters()
#' params[, c("parameter", "default", "units", "citation")]
#'
#' # Only the parameters of the school model
#' measles_parameters("ModelMeaslesSchool")[, c("r_argument", "default")]
#' @export
measles_parameters <- function(model = NULL) {

  fn <- system.file("extdata", "measles_parameters.csv", package = "measles")

  ans <- utils::read.csv(
    fn,
    colClasses = "character",
    na.strings = character(0),
    fileEncoding = "UTF-8"
  )

  if (!is.null(model)) {
    stopifnot_character(model)

    ans <- ans[vapply(
      strsplit(ans$models, ";", fixed = TRUE),
      function(m) model %in% m,
      logical(1)
    ), , drop = FALSE]

    if (nrow(ans) == 0L)
      stop("No parameters found for the model '", model, "'.", call. = FALSE)

    rownames(ans) <- NULL
  }

  ans

}
