#' Get child locations given parent IDs from IHME hierarchies
#'
#' \code{children_of_parents()} finds children from IHME Hierarchies, given a
#' vector of location_ids.v From a hierarchy, which children are have a given
#' parent ID in the path_to_top_parent column?  Returns logical T/F vector.
#'
#' @param parent_loc_ids Numeric vector of parent location_ids
#' @param include_parent Logical T/F Do you want parents included with children?
#'   (FALSE by default). If FALSE, and using two parent IDs, be careful if the
#'   parent location_ids are nested inside each other.
#' @param hierarchy Which hierarchy to use? (Uses 'path_to_top_parent' to find all nested children)
#' @param output Output options:
##' \itemize{
##'  \item{\code{"boolean"} : T/F vector for all rows in the hierarchy - useful for adding a new column}
##'  \item{\code{"numeric"} : vector of only the childrens' location_ids (and parent, if desired)}
##' }
#' @return Logical T/F vector for all hierarchy locs, or a vector of children location_ids?
#' @export
#'
#' @examples
#'
#' source(file.path("/ihme/cc_resources/libraries/current/r/get_location_metadata.R"))
#' hierarchy <- get_location_metadata(location_set_id = 111, location_set_version_id = 1050, release_id = 9)
#'
#' hierarchy$children_of_china <- children_of_parents(6, hierarchy)
#' hierarchy$china_and_children <- children_of_parents(6, hierarchy, include_parent = TRUE)
#'
#' child_locs_of_china <- children_of_parents(6, hierarchy, output = "loc_ids")
#'
children_of_parents <- function(
  parent_loc_ids, # vector of parent location_ids
  hierarchy, # which hierarchy?
  output = "boolean", # output_options <- c("boolean", "loc_ids")
  include_parent = FALSE # include parent with children, or only children?
){
  validate_children_of_parents_inputs(output, hierachy)
  
  result_vec = c()
  for (i in 1:nrow(hierarchy)){
    parent_check_results = c()
    for (parent_id in parent_loc_ids){
      # There is an off-by-one error here. 
      # the current location ID is included in the path_to_top_parent,
      # so to get behavior right for "include_parent", negate the check when location_id == parent_id.
      if (include_parent){
        check = is_child_of_parent(parent_id, hierarchy$path_to_top_parent[i]) 
      } else {
        check = is_child_of_parent(parent_id, hierarchy$path_to_top_parent[i]) & 
          hierarchy$location_id[i] != parent_id
      }
      parent_check_results = c(parent_check_results, check)
    }
    result_vec = c(result_vec, any(parent_check_results))
  }
  
  stopifnot(length(result_vec) == nrow(hierarchy))
  
  if (output == "loc_ids"){
    return(unique(hierarchy[result_vec, location_id]))
  }
  return(result_vec) # Only other option is "boolean"
  
}

#' @description Helper function for children_of_parents. 
validate_children_of_parents_inputs = function(output, hierarchy){
  # check for valid method
  output_options <- c("boolean", "loc_ids")
  if (!(output %in% output_options)) {
    stop("Invalid output argument, please choose:
         boolean, loc_ids")
  }
}

#' @description Helper function for children_of_parents. 
#' Given a single parent_id and a path_to_top_parent, 
#' returns TRUE if that parent_id is in the path. 
#' 
#' @param parent_id [int] Location ID of parent to test
#' @param path_to_top_parent [character] String of path to top parent from hierarchy
#' 
#' @return boolean
is_child_of_parent = function(parent_id, path_to_top_parent){
  path_to_top_parent = as.integer(unlist(strsplit(path_to_top_parent, ",")))
  return(parent_id %in% path_to_top_parent)
}