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
#' When printed, the table shows each parameter with its R argument, in a
#' column named `Parameter (argument)`, and each default with its units, in a
#' column named `Default (units)`. The underlying data frame keeps the
#' separate columns. See [format.measles_parameters()].
#'
#' @param model Optional character scalar with the name of a model function
#' (e.g., `"ModelMeaslesSchool"`). If specified, only the rows of parameters
#' used by that model are returned.
#' @returns A data frame of class `measles_parameters`, with one row per
#' parameter.
#' @examples
#' params <- measles_parameters()
#' params[, c("parameter", "r_argument", "default", "units")]
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

  structure(ans, class = c("measles_parameters", class(ans)))

}

#' Format and print the measles parameter table
#'
#' Fuses the columns of [measles_parameters()] for display: `parameter` and
#' `r_argument` become `Parameter (argument)` (e.g., "Transmission rate
#' (transmission_rate)"), and `default` and `units` become `Default (units)`
#' (e.g., "0.9 (per contact)"), and `citation` and `notes` become
#' `Source (and notes)` (e.g., "Assumption (Note: ...)"). Each pair is fused
#' only when both of its columns are present, so subsets of the table print
#' as well.
#'
#' @param x An object of class `measles_parameters`.
#' @param markdown Logical scalar. If `TRUE`, arguments and defaults are
#' formatted as code, `citation` links to `doi_or_url` (which is then
#' dropped), and `|` is escaped, so the result can be written as a Markdown
#' table.
#' @param ... Further arguments passed to [print.data.frame()].
#' @returns
#' - `format()` returns a data frame with the fused columns.
#' - `print()` returns `x` invisibly.
#' @examples
#' params <- measles_parameters("ModelMeaslesSchool")
#' params[, c("parameter", "r_argument", "default", "units")]
#'
#' # The data frame used for printing
#' format(params[, c("parameter", "r_argument", "default", "units")])
#' @export
format.measles_parameters <- function(x, markdown = FALSE, ...) {

  x <- as.data.frame(unclass(x), stringsAsFactors = FALSE)

  code <- function(v) {
    if (markdown) ifelse(nzchar(v), paste0("`", v, "`"), v) else v
  }

  fuse <- function(x, main, extra, label, wrap_main, wrap_extra,
                   prefix = "") {

    if (!all(c(main, extra) %in% colnames(x)))
      return(x)

    main_val  <- if (wrap_main) code(x[[main]]) else x[[main]]
    extra_val <- if (wrap_extra) code(x[[extra]]) else x[[extra]]

    x[[main]] <- ifelse(
      nzchar(x[[main]]) & nzchar(x[[extra]]),
      paste0(main_val, " (", prefix, extra_val, ")"),
      main_val
    )
    x[[extra]] <- NULL
    colnames(x)[colnames(x) == main] <- label
    x

  }

  if (markdown && all(c("citation", "doi_or_url") %in% colnames(x))) {
    x$citation <- ifelse(
      nzchar(x$doi_or_url),
      paste0(x$citation, " ([link](", x$doi_or_url, "))"),
      x$citation
    )
    x$doi_or_url <- NULL
  }

  x <- fuse(x, "parameter", "r_argument", "Parameter (argument)", FALSE, TRUE)
  x <- fuse(x, "default", "units", "Default (units)", TRUE, FALSE)
  x <- fuse(
    x, "citation", "notes", "Source (and notes)", FALSE, FALSE,
    prefix = "Note: "
  )

  if (markdown)
    x[] <- lapply(x, function(v) gsub("|", "\\|", v, fixed = TRUE))

  x

}

#' @rdname format.measles_parameters
#' @export
print.measles_parameters <- function(x, ...) {
  print(format(x), ...)
  invisible(x)
}
