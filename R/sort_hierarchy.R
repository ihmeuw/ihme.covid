sort_hierarchy <- function(dt, prepend = NULL) {
  # this function uses data.table to do some heavy lifting
  # unfortunately the directions provided for importing do not silence lint errors regarding ":="
  # so we just use #nolint
  # https://cran.r-project.org/web/packages/data.table/vignettes/datatable-importing.html

  lookup <- as.vector(
    data.table::transpose(
      list(
        as.character(dt$location_id),
        dt$location_name),
      make.names = 1))

  # called once (NOT per-row)
  path.as.names <- function(path) {
    # split inputs into a big nested list
    pieces <- strsplit(path, ",")
    # for each row
    sapply(pieces,
      function(piece) {
        # use vector lookup magic to retrieve all location names and collapse into "FOO_BAR"
        paste(lookup[piece], collapse = "_")
        # omit using named values for this
      }, USE.NAMES = FALSE)
  }

  res <- data.table::copy(dt)
  # use a column name we can reasonably expect will never conflict with our data
  res[, sort_lookup_foobarbz1922 := path.as.names(path_to_top_parent)] # nolint
  data.table::setorder(res, sort_lookup_foobarbz1922) # nolint

  # re-sort, taking advantage of *stable sorts*
  # FALSE sorts before TRUE, so we do a reverse sort (denoted with "-")
  if (!is.null(prepend)) {
    res$sort_lookup_foobarbz1922 <- res$location_id %in% prepend
    data.table::setorder(res, -sort_lookup_foobarbz1922) # nolint
  }

  # remove temporary column
  res[, sort_lookup_foobarbz1922 := NULL] # nolint

  return(res)
}
