#' Set state on package load
.onLoad <- function(libname, pkgname) {
  # See "when you do need side-effects"
  # http://r-pkgs.had.co.nz/r.html#r-differences
  op <- options()
  op.ihme.covid <- list(
    "ihme.covid.roots.model-inputs" = "/ihme/covid-19/model-inputs",
    "ihme.covid.versions.model-inputs" = "best"
  )
  # allow users to set these options before loading the package
  # if they do so, respect those values
  toset <- !(names(op.ihme.covid) %in% names(op))
  if (any(toset)) {
    options(op.ihme.covid[toset])
  }

  # now, reflect default values that are necessary for the application to work
  reflect_defaults()

  # enable smart wrapping of functions to spy that does not require attaching ihme.covid
  .spy.on.methods()

  # this makes the return value not auto-REPR in R
  invisible()
}
