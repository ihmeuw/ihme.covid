error_on_missing_locations <- function(data, ..., hierarchy, hierarchy.value = "location_id") {
  if (missing("hierarchy")) {
    stop("hierarchy not provided - must be provided as a named argument")
  }
  miss <- setdiff(hierarchy[[hierarchy.value]], data)
  if (length(miss)) {
    # as.character unsuitable - you need deparse
    # https://stackoverflow.com/a/24632946
    data.name <- deparse(substitute(data))
    stop(sprintf("%s missing values for %s(s): %s", data.name, hierarchy.value, paste(sort(miss), collapse = ",")))
  }
}
