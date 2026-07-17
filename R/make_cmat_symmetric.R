#' Symmetrise a contact matrix based on population sizes
#'
#' The symmetry is achieved to ensure that `n(i) * c(i, j) == n(j) * c(j, i)`
#' where `n(i)` is the population size of age group `i` and `c(i, j)` is the
#' contact rate from age group `i` to age group `j`.
#'
#' @param cmat A contact matrix.
#' @param pop A vector of population sizes for each age group.
#' @details
#' This function was adapted from that described in `socialmixr::symmetrise()`
#' to work with a simple matrix and population vector. The process is
#' implemented as described in the original function, replacing the ij-th
#' entries with `(c_ij * N_i + c_ji * N_j) / 2` and divided by the population
#' size of the respective age group to ensure that the resulting matrix is
#' symmetric with respect to the population sizes.
#'
#' The resulting matrix will satisfy the condition that
#' `n(i) * c(i, j) == n(j) * c(j, i)` for all age groups `i` and `j`, ensuring
#' that the total number of contacts from age group `i` to age group `j` is
#' equal to the total number of contacts from age group `j` to age group `i`.
#'
#' The operation will change the row and column sums of the contact matrix.
#'
#'
#' @examples
#' cmat <- c(4, 2, 1, 3, 5, 6, 4, 5, 2) |>
#'   matrix(nrow = 3, byrow = TRUE)
#' pop <- c(100, 200, 300)
#'
#' cmat_symm <- make_cmat_symmetric(cmat, pop)
#'
#' # Checking symmetry
#' cmat_symm * pop == t(cmat_symm * pop)
#'
#' @export
make_cmat_symmetric <- function(cmat, pop) {

  if (!is.matrix(cmat) || !is.numeric(cmat)) {
    stop("The contact matrix must be a numeric matrix.")
  }

  if (!is.numeric(pop) || length(pop) == 0) {
    stop("The population vector must be a non-empty numeric vector.")
  }

  if (any(!is.finite(pop)) || any(pop <= 0)) {
    stop("The population vector must contain only finite, positive values.")
  }

  if (ncol(cmat) != length(pop)) {
    stop("The number of columns in the contact matrix must match the length of the population vector.")
  }

  if (nrow(cmat) != length(pop)) {
    stop("The number of rows in the contact matrix must match the length of the population vector.")
  }

  for (i in 1:nrow(cmat)) {
    for (j in i:nrow(cmat)) {

      c_ij <- cmat[i, j]
      c_ji <- cmat[j, i]
      N_i <- pop[i]
      N_j <- pop[j]

      c_ij_sym <- (c_ij * N_i + c_ji * N_j) / 2
      cmat[i, j] <- c_ij_sym / N_i
      cmat[j, i] <- c_ij_sym / N_j

    }
  }

  return(cmat)

}
