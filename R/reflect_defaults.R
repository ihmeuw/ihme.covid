#' Reflect default configuration values for ihme.covid based off of filesystem
reflect_defaults <- function() {
  .reflect.locations()
}

.reflect.locations <- function(root = getOption("ihme.covid.roots.model-inputs"), version = getOption("ihme.covid.versions.model-inputs")) {
  path <- file.path(root, version, "locations", "ids.yaml")
  if (file.exists(path)) {
    obj <- yaml::yaml.load_file(path)

    covariate <- obj$covariate
    if (is.null(covariate)) {
      warning(sprintf("No 'covariate' key in %s", path))
    } else {
      options("ihme.covid.locations.covariate" = covariate)
    }

    modeling <- obj$modeling
    if (is.null(modeling)) {
      warning(sprintf("No 'modeling' key in %s", path))
    } else {
      options("ihme.covid.locations.modeling" = modeling)
    }

  } else {
    warning(sprintf("Warning: could not automatically determine covariate/modeling location set versions - %s does not exist", path))
  }
}
