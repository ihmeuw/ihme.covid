#' Assigns common covariate arguments to argparse object
#'
#' @param parser argparse::ArgumentParser instance or equivalent
covariate_args <- function(parser, ..., output_root = "<covariate root>") {
  parser$add_argument("--inputs-directory", default = NULL, help = "model-inputs directory to use. Overrides --model-inputs-version")

  parser$add_argument(
    "--model-inputs-version",
    default = getOption("ihme.covid.versions.model-inputs"),
    help = sprintf("Version of model-inputs to use. Defaults to '%s'", getOption("ihme.covid.versions.model-inputs"))
  )
  covariate.defaults <- getOption("ihme.covid.locations.covariate")
  parser$add_argument(
    "--lsid",
    default = covariate.defaults$location_set_id,
    type = "integer",
    help = "Location set version id"
  )
  parser$add_argument(
    "--lsvid",
    default = covariate.defaults$location_set_version_id,
    type = "integer",
    help = "Location set version id"
  )
  parser$add_argument(
    "--outputs-directory",
    help = sprintf("Directory to write outputs to. Defaults to %s/YYYY_MM_DD.VV for today's date", output_root)
  )
}
