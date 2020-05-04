test_that("print_debug is convenient and clear", {
  foo <- 4
  bar <- 7
  msg <- "This is not a test"

  expect_message(print_debug(foo), "foo: 4")

  expect_message(print_debug(foo, bar, msg), "foo: 4")
  expect_message(print_debug(foo, bar, msg), "bar: 7")
  expect_message(print_debug(foo, bar, msg), "msg: This is not a test")
})

test_that("Typos, NA, and NULL values are handled", {
  nu <- NULL
  na <- NA

  expect_message(print_debug(na), "na: NA")
  expect_message(print_debug(nu), "nu: NULL")
  expect_message(print_debug(baz), "baz: ERROR - no baz defined")
})
