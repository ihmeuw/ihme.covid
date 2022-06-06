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
  
  # check for valid method
  output_options <- c("boolean", "loc_ids")
  if (!(output %in% output_options)) {
    stop("Invalid output argument, please choose:
         boolean, loc_ids")
  }
  
  
  path_to_parent_string <- hierarchy$path_to_top_parent
  
  if (output == "boolean") {
    
    child_TF <- c()
    
    for(i in 1:length(path_to_parent_string)){
      X <- as.numeric(unlist(strsplit(path_to_parent_string[i], ",")))
      
      if(include_parent){
        child_TF[i] <- any(parent_loc_ids %in% X)
        
      } else if (!include_parent) {
        if(any(parent_loc_ids == X[length(X)])) {
          child_TF[i] <- FALSE
          
        } else {
          child_TF[i] <- any(parent_loc_ids %in% X)
          
        }
      }
    }
    
    return_vec <- child_TF
    
  } else if (output == "loc_ids"){
    
    child_TF <- c()
    
    for(i in 1:length(path_to_parent_string)){
      X <- as.numeric(unlist(strsplit(path_to_parent_string[i], ",")))
      
      if(include_parent){
        child_TF[i] <- any(parent_loc_ids %in% X)
        
      } else if (!include_parent) {
        if(any(parent_loc_ids == X[length(X)])) {
          child_TF[i] <- FALSE
          
        } else {
          child_TF[i] <- any(parent_loc_ids %in% X)
          
        }
      }
    }
    
    hierarchy$child_TF <- child_TF
    return_vec <- hierarchy$location_id[which(child_TF)]
    
  }
  
  
  return(return_vec)
  
}