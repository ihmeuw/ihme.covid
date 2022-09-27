# Hierarchy with Washington, Arkansas, USA, Rajasthan, India, and Global
test_hier = data.table::data.table(
  'location_id' = c(570, 526, 102, 4868, 163, 1),
  'path_to_top_parent' = c(
    '570,102,1', 
    '526,102,1',
    '102,1',
    '4868,163,1',
    '163,1',
    '1'
  ),
  'level' = c(3, 3, 2, 3, 2, 1)
)

test_that("children_of_parents includes parent when asked", {
  # Test output = 'loc_ids'
  result = children_of_parents(
    parent_loc_ids = 102,
    hierarchy = test_hier, 
    output = 'loc_ids',
    include_parent = FALSE
  )
  expect_setequal(result, c(570, 526))
  
  result = children_of_parents(
    parent_loc_ids = 102,
    hierarchy = test_hier, 
    output = 'loc_ids',
    include_parent = TRUE
  )
  expect_setequal(result, c(570, 526, 102))
  
  # Test output = 'boolean'
  result = children_of_parents(
    parent_loc_ids = 102,
    hierarchy = test_hier, 
    output = 'boolean',
    include_parent = FALSE
  )
  expect_equal(result, c(TRUE, TRUE, FALSE, FALSE, FALSE, FALSE))
  
  result = children_of_parents(
    parent_loc_ids = 102,
    hierarchy = test_hier, 
    output = 'boolean',
    include_parent = TRUE
  )
  expect_equal(result, c(TRUE, TRUE, TRUE, FALSE, FALSE, FALSE))
})

test_that("children_of_parents throws expected errors", {
  expect_error(
    children_of_parents(
      parent_loc_ids = 102,
      hierarchy = test_hier, 
      output = 'not an output',
      include_parent = FALSE
    ), regexp = "Invalid output argument, please choose"
  )
  
  expect_error(
    children_of_parents(
      parent_loc_ids = c('1', '102'),
      hierarchy = test_hier, 
      output = 'not an output',
      include_parent = FALSE
    ), regexp = "Invalid parent_loc_ids type, please provide an integer vector of location_id's"
  )
  
  bad_hier = data.table::copy(test_hier)
  bad_hier$path_to_top_parent = NULL
  expect_error(
    children_of_parents(
      parent_loc_ids = 102,
      hierarchy = bad_hier, 
      output = 'boolean',
      include_parent = FALSE
    ), regexp = "Was passed an invalid hierarchy. Must have columns path_to_top_parent and location_id."
  )
})

test_that("You can pass an n-length vector of parent IDs", {
  result = children_of_parents(
    parent_loc_ids = c(102, 1),
    hierarchy = test_hier, 
    output = 'loc_ids',
    include_parent = FALSE
  )
  expect_equal(result, c(570, 526, 102, 4868, 163))
  
  result = children_of_parents(
    parent_loc_ids = c(102, 1),
    hierarchy = test_hier, 
    output = 'loc_ids',
    include_parent = TRUE
  )
  expect_equal(result, c(570, 526, 102, 4868, 163, 1))
  
  result = children_of_parents(
    parent_loc_ids = c(102, 163),
    hierarchy = test_hier, 
    output = 'loc_ids',
    include_parent = FALSE
  )
  expect_equal(result, c(570, 526, 4868))
})

test_that("is_child_of_parent helper function works", {
  expect_true(is_child_of_parent(102, test_hier[location_id==570, path_to_top_parent]))
  expect_false(is_child_of_parent(163, test_hier[location_id==570, path_to_top_parent]))
})
