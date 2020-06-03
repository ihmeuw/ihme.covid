.reset.input.files <- function() {
  ihme.covid::get.input.files(clear = TRUE)
}

test_that("fread captured", {
  # cleanup code
  on.exit(.reset.input.files(), add = TRUE)

  # precondition
  expect_equal(length(get.input.files()), 0)

  suppressWarnings(fread("/dev/null"))
  i.f <- get.input.files()
  expect_equal(length(i.f), 1)
  expect_equal(i.f[[1]]$path, "/dev/null")
})


test_that("get.input.files() result is not a shared reference", {
  suppressWarnings(fread("/dev/null"))

  i.f <- get.input.files()
  i.f[[1]]$path <- "hello"

  expect_equal(get.input.files()[[1]]$path, "/dev/null")
})
