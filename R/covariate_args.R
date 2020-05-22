#' Assigns common covariate arguments to argparse object
#'
#' @param parser argparse::ArgumentParser instance or equivalent
covariate_args <- function(parser, ..., output_root = "<covariate root>") {
  parser$add_argument("--lsid", default = 111, type = "integer", help = "Location set version id. Defaults to 111")
  parser$add_argument("--lsvid", required = TRUE, type = "integer", help = "Location set version id")
  parser$add_argument("--model-inputs-version", default = "best", help = "Version of model-inputs to use. Defaults to 'best'")
  parser$add_argument("--inputs-directory", default = NULL, help = "model-inputs directory to use. Overrides --model-inputs-version")
  parser$add_argument(
    "--outputs-directory",
    help = sprintf("Directory to write outputs to. Defaults to %s/YYYY_MM_DD.VV for today's date", output_root)
  )
}
