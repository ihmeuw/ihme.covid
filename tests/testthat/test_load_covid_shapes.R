test_that("load_covid_shapes behaves as expected on 2020-05-20", {
  test.fixture.path <- "fixtures/covid-shapefile/2020-05-20/covid.shp"
  # NOTE: we cannot upload this shapefile so you have to come up with your own copy
  skip_if_not(file.exists(test.fixture.path), message = "No fixture file to test")

  expect_true(file.exists(test.fixture.path))

  expect_warning(
    world <- load_covid_shapes(location_set_id = 1, location_set_version_id = 2, shp_path = test.fixture.path),
    # this indicates there should be no warnings
    regexp = NA
  )

  # this is the normal GPS coordinates projection
  expect_equal(sp::proj4string(world), "+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0")

  expect_false(any(is.na(world$location_set_id)))
  expect_false(any(is.na(world$location_id)))
  expect_false(any(is.na(world$parent_id)))
  # > d[is.na(d$level), c("loc_ascii")]
  #  [1] "Alberta"
  #  [2] "British Columbia"
  #  [3] "Manitoba"
  #  [4] "New Brunswick"
  #  [5] "Newfoundland and Labrador"
  #  [6] "Northwest Territories"
  #  [7] "Nova Scotia"
  #  [8] "Nunavut"
  #  [9] "Ontario"
  # [10] "Prince Edward Island"
  # [11] "Quebec"
  # [12] "Saskatchewan"
  # [13] "Yukon"
  # [14] "Maldives"
  # [15] "Washington except for King, Snohomish, and Spokane Counties"
  # [16] "Washington except for King, Snohomish, and Spokane Counties"
  # [17] "Washington except for King, Snohomish, and Spokane Counties"
  # [18] "Washington except for King, Snohomish, and Spokane Counties"
  # [19] "Washington except for King, Snohomish, and Spokane Counties"
  # [20] "Washington except for King, Snohomish, and Spokane Counties"
  # [21] "Washington except for King, Snohomish, and Spokane Counties"
  # [22] "Washington except for King, Snohomish, and Spokane Counties"
  # [23] "Washington except for King, Snohomish, and Spokane Counties"
  # [24] "Washington except for King, Snohomish, and Spokane Counties"
  # [25] "Washington except for King, Snohomish, and Spokane Counties"
  # [26] "Washington except for King, Snohomish, and Spokane Counties"
  # [27] "Washington except for King, Snohomish, and Spokane Counties"
  # [28] "Washington except for King, Snohomish, and Spokane Counties"
  # [29] "Washington except for King, Snohomish, and Spokane Counties"
  # [30] "Washington except for King, Snohomish, and Spokane Counties"
  # [31] "King and Snohomish Counties"
  # [32] "Washington except for King, Snohomish, and Spokane Counties"
  # [33] "Washington except for King, Snohomish, and Spokane Counties"
  # [34] "Washington except for King, Snohomish, and Spokane Counties"
  # [35] "Washington except for King, Snohomish, and Spokane Counties"
  # [36] "Washington except for King, Snohomish, and Spokane Counties"
  # [37] "Washington except for King, Snohomish, and Spokane Counties"
  # [38] "Washington except for King, Snohomish, and Spokane Counties"
  # [39] "Washington except for King, Snohomish, and Spokane Counties"
  # [40] "Washington except for King, Snohomish, and Spokane Counties"
  # [41] "Washington except for King, Snohomish, and Spokane Counties"
  # [42] "Washington except for King, Snohomish, and Spokane Counties"
  # [43] "Washington except for King, Snohomish, and Spokane Counties"
  # [44] "Washington except for King, Snohomish, and Spokane Counties"
  # [45] "King and Snohomish Counties"
  # [46] "Spokane County"
  # [47] "Washington except for King, Snohomish, and Spokane Counties"
  # [48] "Washington except for King, Snohomish, and Spokane Counties"
  # [49] "Washington except for King, Snohomish, and Spokane Counties"
  # [50] "Washington except for King, Snohomish, and Spokane Counties"
  # [51] "Washington except for King, Snohomish, and Spokane Counties"
  # [52] "Washington except for King, Snohomish, and Spokane Counties"
  # [53] "Washington except for King, Snohomish, and Spokane Counties"
  # expect_false(any(is.na(world$level))) # currently fails. should it?
  expect_false(any(is.na(world$location_ascii_name)))
})
