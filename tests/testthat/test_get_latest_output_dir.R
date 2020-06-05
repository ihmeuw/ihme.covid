test_that("get_latest_output_dir works", {
  latest_dir <- get_latest_output_dir(root = "fixtures/versioned-dirs/nested/1999_09_09")

  expect_equal(latest_dir, "fixtures/versioned-dirs/nested/1999_09_09/1999_09_09.02")
})

test_that("get_latest_output_dir errors correctly", {
  expect_error(
    get_latest_output_dir(root = "fixtures/DOES-NOT-EXIST"),
    "root fixtures/DOES-NOT-EXIST does not exist"
  )

  expect_error(
    get_latest_output_dir(root = "fixtures/versioned-dirs"),
    "No YYYY_MM_DD.VV directories in fixtures/versioned-dirs"
  )
})
