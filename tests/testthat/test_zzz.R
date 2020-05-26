test_that("zzz.R .onLoad sets required defaults", {
  default.model.inputs <- getOption("ihme.covid.roots.model-inputs")

  expect_false(is.null(default.model.inputs))
  expect_equal(default.model.inputs, "/ihme/covid-19/model-inputs")
})
