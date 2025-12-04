#' Add entities to a model according to a data.frame
#'
#' Helper function that facilities creating entities and adding them to
#' models. It is a wrapper of [epiworldR::add_entity()].
#'
#' @param model An [epiworld_model] object.
#' @param entities A `data.frame` with the entities to add. It must contain two
#' columns: entity names (character) and size (proportion or integer).
#' @param col_name The name of the column in `entities` that contains the
#' entity names.
#' @param col_number The name of the column in `entities` that contains the
#' entity sizes (either as proportions or integers).
#' @param ... Further arguments passed to [epiworldR::add_entity()]
#' @returns
#' Inivisible the model with the added entities.
#' @examples
#' # Start off creating three entities.
#' # Individuals will be distributed randomly between the three.
#' entities <- data.frame(
#'   name = c("Pop 1", "Pop 2", "Pop 3"),
#'   size = rep(3e3, 3)
#' )
#'
#' # Row-stochastic matrix (rowsums 1)
#' cmatrix <- c(
#'   c(0.9, 0.05, 0.05),
#'   c(0.1, 0.8, 0.1),
#'   c(0.1, 0.2, 0.7)
#' ) |> matrix(byrow = TRUE, nrow = 3)
#'
#' measles_model <- ModelMeaslesMixing(
#'   n               = 9000,
#'   prevalence      = 1 / 9000,
#'   contact_rate    = 15,
#'   contact_matrix  = cmatrix,
#'   prop_vaccinated = .8
#' ) |>
#'   entities_from_dataframe(
#'     entities = entities,
#'     col_name = "name",
#'     col_number = "size",
#'     # This is passed to `epiworldR::add_entity()`
#'     as_proportion = FALSE
#'   )
#' @export
entities_from_dataframe <- function(
  model,
  entities,
  col_name,
  col_number,
  ...
) {
  # Basic checker
  stopifnot_model(model)

  if (!inherits(entities, "data.frame"))
    stop(
      "The argument `entities` must be a data.frame. It is of class: ",
      paste(class(entities), collapse = ", ")
    )

  # Checking the columns
  if (!inherits(entities[[col_name]], "character"))
    stop(
      "The column `col_name` (", col_name, ") should be of class",
      "`character`, but it is of class ",
      paste(class(entities[[col_name]]), collapse = ", ")
    )

  if (!inherits(entities[[col_number]], "numeric"))
    stop(
      "The column `col_number` (", col_number, ") should be of class",
      "`numeric`, but it is of class ",
      paste(class(entities[[col_number]]), collapse = ", ")
    )

  # Iterating through the rows
  for (i in seq_len(nrow(entities))) {

    e <- epiworldR::entity(
      name = entities[[col_name]][i],
      prevalence = entities[[col_number]][i],
      ...
    )

    epiworldR::add_entity(model, e)

  }

  invisible(model)

}
