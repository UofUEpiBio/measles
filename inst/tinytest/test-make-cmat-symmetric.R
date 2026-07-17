# Test just this file:
# tinytest::run_test_file("inst/tinytest/test-make-cmat-symmetric.R")

cmat <- matrix(c(4, 2, 1, 3, 5, 6, 4, 5, 2), nrow = 3, byrow = TRUE)
pop  <- c(100, 200, 300)

cmat_symm <- make_cmat_symmetric(cmat, pop)

# ------------------------------------------------------------------------------
# Reciprocity: n(i) * c(i, j) == n(j) * c(j, i)
# ------------------------------------------------------------------------------
expect_equal(cmat_symm * pop, t(cmat_symm * pop))

# Within-group (diagonal) contact rates are left unchanged
expect_equal(diag(cmat_symm), diag(cmat))

# A matrix that is already reciprocal is returned unchanged
sym <- matrix(c(2, 4, 6, 2, 5, 5, 2, 10 / 3, 4), nrow = 3, byrow = TRUE)
expect_equal(make_cmat_symmetric(sym, pop), sym)

# ------------------------------------------------------------------------------
# Input validation
# ------------------------------------------------------------------------------
# cmat must be a numeric matrix
expect_error(make_cmat_symmetric(1:9, pop), "numeric matrix")
expect_error(make_cmat_symmetric(matrix(letters[1:9], 3), pop), "numeric matrix")

# pop must be a non-empty numeric vector
expect_error(make_cmat_symmetric(cmat, "a"), "non-empty numeric vector")
expect_error(make_cmat_symmetric(cmat, numeric(0)), "non-empty numeric vector")

# pop must be finite and positive (it is used as a divisor)
expect_error(make_cmat_symmetric(cmat, c(0, 200, 300)), "finite, positive")
expect_error(make_cmat_symmetric(cmat, c(-1, 200, 300)), "finite, positive")
expect_error(make_cmat_symmetric(cmat, c(NA, 200, 300)), "finite, positive")

# Dimensions of cmat and pop must agree
expect_error(make_cmat_symmetric(cmat, c(100, 200)), "number of columns")
expect_error(make_cmat_symmetric(matrix(1:6, nrow = 2), pop), "number of rows")
