test_that("sort_hierarchy defaults to sorting by name and includes subnationals", {
  USA <- "United States of America"
  USA.WA <-  "Washington"
  USA.WA.SC <- "Spokane County"
  USA.WA.KCSC <- "King and Snohomish Counties"
  USA.WA.OTHER <- "Washington except for King, Snohomish, and Spokane Counties"
  ITA <- "Italy"
  dt <- data.table::data.table(
    location_id = c(102, 570, 3539, 60886, 60887, 86),
    location_name = c(USA, USA.WA, USA.WA.SC, USA.WA.KCSC, USA.WA.OTHER, ITA),
    path_to_top_parent = c("102", "102,570", "102,570,3539", "102,570,60886", "102,570,60887", "86")
  )

  sorted <- sort_hierarchy(dt)

  expect_equal(
    sorted$location_name,
    c(ITA, USA, USA.WA, USA.WA.KCSC, USA.WA.SC, USA.WA.OTHER)
  )
})

test_that("arbitrary locations can be selected by location_id and moved to the front", {
  USA <- "United States of America"
  USA.WA <-  "Washington"
  USA.WA.SC <- "Spokane County"
  USA.WA.KCSC <- "King and Snohomish Counties"
  USA.WA.OTHER <- "Washington except for King, Snohomish, and Spokane Counties"
  ITA <- "Italy"
  dt <- data.table::data.table(
    location_id = c(102, 570, 3539, 60886, 60887, 86),
    location_name = c(USA, USA.WA, USA.WA.SC, USA.WA.KCSC, USA.WA.OTHER, ITA),
    path_to_top_parent = c("102", "102,570", "102,570,3539", "102,570,60886", "102,570,60887", "86")
  )

  sorted <- sort_hierarchy(dt, prepend = c(60886, 3539))

  expect_equal(
    sorted$location_name,
    c(USA.WA.KCSC, USA.WA.SC, ITA, USA, USA.WA, USA.WA.OTHER)
  )
})
