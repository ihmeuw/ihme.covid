test_that("zzz.R .onLoad sets required defaults", {
  default.model.inputs.path <- getOption("ihme.covid.roots.model-inputs")

  expect_false(is.null(default.model.inputs.path))
  expect_equal(default.model.inputs.path, "/ihme/covid-19/model-inputs")


  default.model.inputs.version <- getOption("ihme.covid.versions.model-inputs")
  expect_false(is.null(default.model.inputs.version))
  expect_equal(default.model.inputs.version, "best")
})
