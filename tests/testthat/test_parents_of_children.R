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
  
  res = parents_of_children(
    child_loc_ids = c(102),
    hierarchy = test_hier, 
    parent_level = 1,
    output = 'loc_ids'
  )
  expect_equal(res, 1)
})