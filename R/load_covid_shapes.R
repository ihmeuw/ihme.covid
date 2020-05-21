load_covid_shapes <- function(location_set_id, location_set_version_id, shp_path = NULL) {
  if (is.null(shp_path)) {
    shp_path <- "/ihme/covid-19/model-inputs/best/unversioned-inputs/SHAPEFILES/covid.shp"
  }

  # TODO: get the shapefiles to a point that you can actually use these arguments to pick the correct one!
  world <-  rgdal::readOGR(shp_path, stringsAsFactors = FALSE)

  output.fields <- c(
    "location_set_id",
    "location_set_version_id",
    "location_id",
    "parent_id",
    "path_to_top_parent",
    "level",
    "location_ascii_name"
    )

  # handle existing and desired future schema of shapefile
  if ("loc_nam" %in% names(world)) { # existing schema
    # fill in missing path_to_top_parent with poor proxy
    world@data$fail1 <- "No path_to_top_parent available for this covid release"

    data.table::setnames(
      world@data,
      c("loc_id", "parnt_d", "fail1", "level", "loc_ascii"),
      output.fields[3:length(output.fields)] # TODO: there's got to be a better way
    )

    # fill in other columns
    world@data$location_set_id <- location_set_id
    world@data$location_set_version_id <- location_set_version_id

    # convert known bad types
    world@data$location_id <- as.numeric(world@data$location_id)
    world@data$parent_id <- as.numeric(world@data$location_id)
    world@data$level <- as.numeric(world@data$level)

    # fill in 1 missing data point - i pulled this from the location hierarchy
    world@data[world@data$location_id == 44533, "location_ascii_name"] <- "China (without Hong Kong and Macao)"
  } else { # desired schema?
    # Per Mike/Julia thread
    # https://ihme.slack.com/archives/C0110RN8TAT/p1589998413476900?thread_ts=1589935754.446100&cid=C0110RN8TAT
    data.table::setnames(
      world@data,
      c("lsid", "lsvid", "loc_id", "parent_id", "pttp", "level", "loc_name"),
      output.fields
    )
  }

  classes <- lapply(world@data, class)
  warn.on.type <- function(column, type.name) {
    if (classes[[column]] != type.name) {
      warning(sprintf("Column '%s' should have type '%s' but has type '%s' - CHECK YOUR DATA", column, type.name, classes[[column]]))
    }
  }

  warn.on.type("location_set_id", "numeric")
  warn.on.type("location_set_version_id", "numeric")
  warn.on.type("location_id", "numeric")
  warn.on.type("parent_id", "numeric")
  warn.on.type("path_to_top_parent", "character")
  warn.on.type("level", "numeric")
  warn.on.type("location_ascii_name", "character")
  return(world)
}
