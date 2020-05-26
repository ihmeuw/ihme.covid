test_that("Default values are correctly reflected from filesystem + options", {
  old.options <- options(
    # path is relative to the directory this test file is in
    "ihme.covid.roots.model-inputs" = "fixtures/model-inputs",
    "ihme.covid.versions.model-inputs" = "2020_05_25.02"
  )
  # re-set values at end of this function
  on.exit(options(old.options), add = TRUE)

  reflect_defaults()

  expect_equal(getOption("ihme.covid.locations.covariate"), list(location_set_id = 111, location_set_version_id = 680))
  expect_equal(getOption("ihme.covid.locations.modeling"), list(location_set_id = 111, location_set_version_id = 674))
})
