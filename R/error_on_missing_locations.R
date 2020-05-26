#' Error on missing locations in hierarchy
#'
#' Compares data to location hierarchy to ensure that data has values present for each hierarchy entry.
#' Issues a \code{stop} if any values are missing.
#'
#' @param data vector-like with values corresponding to the location hierarchy
#' @param ... captures other arguments. Do not provide any or you will get an error.
#' @param hierarchy IHME location hierarchy from e.g., \code{get_location_metadata}
#' @param hierarchy.value the value in the hierarchy to compare to. Default: "location_id"
error_on_missing_locations <- function(data, ..., hierarchy, hierarchy.value = "location_id") {
  if (missing("hierarchy")) {
    stop("hierarchy not provided - must be provided as a named argument")
  }
  if (length(list(...)) != 0) {
    stop("Invalid extra arguments - provide only one positional arg (data) + hierarchy + optional hierarchy.value")
  }
  miss <- setdiff(hierarchy[[hierarchy.value]], data)
  if (length(miss)) {
    # as.character unsuitable - you need deparse
    # https://stackoverflow.com/a/24632946
    data.name <- deparse(substitute(data))
    stop(sprintf("%s missing values for %s(s): %s", data.name, hierarchy.value, paste(sort(miss), collapse = ",")))
  }
}
