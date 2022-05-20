.reset.input.files <- function() {
  ihme.covid::get.input.files(clear = TRUE)
}

test_that("read.csv captured", {
  # NOTE: read.csv is part of the utils package, which is automatically loaded
  # on R startup. This will always be present in the environment, and
  # ihme.covid will always immediately replace it

  # cleanup code
  on.exit(.reset.input.files(), add = TRUE)

  # precondition
  expect_equal(length(get.input.files()), 0)

  suppressWarnings(read.csv("fixtures/data.csv"))
  i.f <- get.input.files()
  expect_equal(length(i.f), 1)
  expect_equal(i.f[[1]]$path, normalizePath("fixtures/data.csv"))
})


test_that("fread replaced as expected when data.table is loaded after ihme.covid", {
  expect_false(exists("fread"))

  library(data.table)
  on.exit(detach("package:data.table", unload = TRUE), add = TRUE)
                 
  expect_true(exists("fread"))

  fread.env.name <- environmentName(environment(fread))
  expect_equal(fread.env.name, "ihme.covid")
})


test_that("fread captured", {
  # cleanup code
  on.exit(.reset.input.files(), add = TRUE)
  on.exit(detach("package:data.table", unload = TRUE), add = TRUE)

  # precondition
  expect_equal(length(get.input.files()), 0)

  library(data.table)
  suppressWarnings(fread("/dev/null"))
  i.f <- get.input.files()
  expect_equal(length(i.f), 1)
  expect_equal(i.f[[1]]$path, "/dev/null")
})


test_that("read_excel captured", {
  # cleanup code
  on.exit(.reset.input.files(), add = TRUE)
  on.exit(detach("package:readxl", unload = TRUE), add = TRUE)

  # precondition
  expect_equal(length(get.input.files()), 0)

  library(readxl)
  read_excel("fixtures/closure_criteria_sheet.xlsx")
  i.f <- get.input.files()
  expect_equal(length(i.f), 1)
  expect_equal(i.f[[1]]$path, normalizePath("fixtures/closure_criteria_sheet.xlsx"))
})


test_that("get.input.files() result is not a shared reference", {
  suppressWarnings(read.csv("fixtures/data.csv"))

  i.f <- get.input.files()
  i.f[[1]]$path <- "hello"

  expect_equal(get.input.files()[[1]]$path, normalizePath("fixtures/data.csv"))
})


test_that("get.metadata has expected keys", {
  result <- get.metadata("/dev/null")

  expect_setequal(
    names(result),
    c("path", "access_time", "last_modified")
  )
})
