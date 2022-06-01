# helper functions
mock.args.kwargs <- function(mock) {
  args <- mockery::mock_args(mock)

  call.args.kwargs <- function(call) {
    c <- as.list(call)
    args <- c[which(names(c) == "")]
    kwargs <- c[which(names(c) != "")]

    list(args = args, kwargs = kwargs)
  }

  lapply(args, call.args.kwargs)
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
  # setup - define ihme.covid.locations.covariate which is normally done in package load using .onAttach
  options("ihme.covid.locations.covariate" = list(location_set_id = 111, location_set_version_id = 680))
  
  skip("Don't have access to mockery on this image")
  parser <- list(add_argument = mockery::mock())
  covariate_args(parser)

  args_kwargs <- mock.args.kwargs(parser$add_argument)

  get.call.for.flag(args_kwargs, "--outputs-directory")

  get.call.for.flag(args_kwargs, "--inputs-directory")

  lsvid <- get.call.for.flag(args_kwargs, "--lsvid")
  expect_equal(lsvid$kwargs$type, "integer")
  expect_equal(lsvid$kwargs$default, 680)

  lsid <- get.call.for.flag(args_kwargs, "--lsid")
  expect_equal(lsid$kwargs$type, "integer")
  expect_equal(lsid$kwargs$default, 111)

  miv <- get.call.for.flag(args_kwargs, "--model-inputs-version")
  expect_equal(miv$kwargs$default, "best")

})
