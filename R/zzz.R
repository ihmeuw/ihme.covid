#' Set state on package load
.onLoad <- function(libname, pkgname) {
  # See "when you do need side-effects"
  # http://r-pkgs.had.co.nz/r.html#r-differences
  op <- options()
  op.ihme.covid <- list(
    "ihme.covid.roots.model-inputs" = "/ihme/covid-19/model-inputs",
    "ihme.covid.versions.model-inputs" = "best"
  )
  toset <- !(names(op.ihme.covid) %in% names(op))
  if (any(toset)) {
    options(op.ihme.covid[toset])
  }

  # this makes the return value not auto-REPR in R
  invisible()
}
