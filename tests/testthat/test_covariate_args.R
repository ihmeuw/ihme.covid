# helper functions
mock.args.kwargs <- function(mock) {
  calls <- mockery::mock_calls(mock)

  call.args.kwargs <- function(call) {
    c <- as.list(call)
    args <- c[which(names(c) == "")][-1] # omit first value, which is parser$add_argument
    kwargs <- c[which(names(c) != "")]

    list(args = args, kwargs = kwargs)
  }

  lapply(calls, call.args.kwargs)
}

#' Returns call for specified flag.
#'
#' Calls testthat:fail if not found, so you can assert that the flag was provided just by calling this.
get.call.for.flag <- function(args_kwargs, flag) {
  for (arg_kwarg in args_kwargs) {
    if (any(flag %in% arg_kwarg$args)) {
      return(arg_kwarg)
    }
  }
  testthat::fail(sprintf("Did not find call for flag %s", flag))
}

test_that("covariate_args adds all expected arguments", {
  parser <- list(add_argument = mockery::mock())

  covariate_args(parser)

  args_kwargs <- mock.args.kwargs(parser$add_argument)

  get.call.for.flag(args_kwargs, "--outputs-directory")

  get.call.for.flag(args_kwargs, "--inputs-directory")

  lsvid <- get.call.for.flag(args_kwargs, "--lsvid")
  expect_equal(lsvid$kwargs$type, "integer")
  expect_true(lsvid$kwargs$required)

  lsid <- get.call.for.flag(args_kwargs, "--lsid")
  expect_equal(lsid$kwargs$type, "integer")
  expect_equal(lsid$kwargs$default, 111)

  miv <- get.call.for.flag(args_kwargs, "--model-inputs-version")
  expect_equal(miv$kwargs$default, "best")

})
