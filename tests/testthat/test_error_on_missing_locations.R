test_that("errors are generated on missing values for location_ids", {
  hierarchy <- data.table::data.table(location_id = 1:5)
  my_data <- c(1, 2, 6) # lacks values for 3, 4, 5 (all in hierarchy)

  # must error
  expect_error(error_on_missing_locations(my_data, hierarchy = hierarchy))

  # error must include the missing values
  expect_error(error_on_missing_locations(my_data, hierarchy = hierarchy),
    "missing values for location_id(s): 3,4,5",
    fixed = TRUE # test fixed string value, not regex
  )
})


test_that("error_on_missing_locations can use non-location_id fields", {
  hierarchy <- data.table::data.table(location_name = c("Russia", "USA"))
  my_data <- c("USA", "USA")

  expect_error(
    error_on_missing_locations(my_data, hierarchy = hierarchy, hierarchy.value = "location_name"),
    "missing values for location_name(s): Russia",
    fixed = TRUE
  )
})

test_that("error_on_missing_locations required hierarchy as a named argument", {
  hierarchy <- data.table::data.table(location_id = 1:5)
  my_data <- c(1, 2, 6)

  expect_error(error_on_missing_locations(my_data, hierarchy),
    "hierarchy not provided - must be provided as a named argument"
  )
})


test_that("error_on_missing_locations provides name of value", {
  hierarchy <- data.table::data.table(location_id = 1:5)
  my_data <- list(ids = c(1, 2, 6))

  expect_error(
    error_on_missing_locations(my_data$ids, hierarchy = hierarchy),
    "my_data$ids missing values for location_id(s): 3,4,5",
    fixed = TRUE
  )
})
