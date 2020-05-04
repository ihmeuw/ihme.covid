test_that("get_latest_output_date_index returns 0 if no dirs exist", {
  # neither of these directories exist
  expect_equal(0, get_latest_output_date_index("/does/not/exist", date = "2001_01_01"))
  expect_equal(0, get_latest_output_date_index("fixtures/versioned-dirs/2000_01_01", date = "2001_01_01"))
})

test_that("get_latest_output_date_index returns correct value", {
  expect_equal(2, get_latest_output_date_index("fixtures/versioned-dirs/nested/1999_09_09", date = "1999_09_09"))
})
