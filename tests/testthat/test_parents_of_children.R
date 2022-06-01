# Hierarchy with Washington, Arkansas, USA, and Global
test_hier = data.table(
  'location_id' = c(570, 526, 102, 1),
  'path_to_top_parent' = c(
    '570,102,1', 
    '526,102,1',
    '102,1',
    '1'
  ),
  'level' = c(3, 3, 2, 1)
)

test_that("parents_of_children works", {
  # A single child
  res = parents_of_children(
    child_loc_ids = 102,
    hierarchy = test_hier, 
    parent_level = 1
  )
  expect_equal(res, 1)
  
  # Multiple children
  res = parents_of_children(
    child_loc_ids = c(102, 570),
    hierarchy = test_hier, 
    parent_level = 1
  )
  expect_equal(res, c(1, 1))
})

test_that("parents_of_children throws expected errors", {
  expect_error(
    parents_of_children(
      child_loc_ids = c(102),
      hierarchy = test_hier, 
      parent_level = -2
    ), regexp = "Level is not available in hierarchy"
  )
  
  bad_hierarchy = copy(test_hier)
  bad_hierarchy$path_to_top_parent <- NULL
  expect_error(
    parents_of_children(
      child_loc_ids = c(102),
      hierarchy = bad_hierarchy, 
      parent_level = 1
    ), regexp = "Was passed an invalid hierarchy"
  )
  
  expect_error(
    parents_of_children(
      child_loc_ids = c(777),
      hierarchy = test_hier, 
      parent_level = 1
    ), regexp = "Child location is not in hierarchy!"
  )
  
  expect_error(
    parents_of_children(
      child_loc_ids = 102,
      hierarchy = test_hier, 
      parent_level = 3
    ), regexp = "Parent level 3 and child level 2 are incompatible"
  )
})