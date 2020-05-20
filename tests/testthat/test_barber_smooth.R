test_that("The function runs", {
  vec <- c(1, 7, 5, 6, 19, 10)
  smoothed <- barber_smooth(vec, n_neighbors = 2, times = 1)

  expect_equal(length(smoothed), 6)
  expect_equal(class(smoothed), "matrix")
  expect_equal(
    smoothed,
    matrix(data = c(2.79, 3.81, 5.25, 8.32, 8.69, 10.93)),
    tolerance = 1e-3
  )
})
