test_that("get_output_dir functionality works", {
  # create random root directory
  root <- system("mktemp -d", intern = TRUE)
  # run this cleanup code as teardown for the test
  teardown(unlink(root, recursive = TRUE))

  # expect bootstrap to work
  expect_equal(file.path(root, "1999_09_09.01"), get_output_dir(root = root, date = "1999_09_09"))
  expect_true(dir.exists(file.path(root, "1999_09_09.01")))

  # incrementing automatically happens
  expect_equal(file.path(root, "1999_09_09.02"), get_output_dir(root = root, date = "1999_09_09"))

  # handle convenience "today" value
  today.v1 <- format(Sys.Date(), "%Y_%m_%d.01")
  expect_equal(file.path(root, today.v1), get_output_dir(root = root, date = "today"))
})
