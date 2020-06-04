# Not exported. Tracks input files used for those functions we track
# Global state for our package, but not globally available
.input.files <- list()

.append.input.file <- function(metadata) {
  # TODO: check for duplicates in case e.g., someone re-ran something because it crashed midway
  .input.files[[length(.input.files) + 1]] <- metadata
  # we need to re-assign this due to how the package value (which is not a global value) is managed by R
  assignInNamespace(".input.files", .input.files, ns = packageName())
}

get.input.files <- function(clear = FALSE) {
  result <- .input.files
  if (clear) {
    assignInNamespace(".input.files", list(), ns = packageName())
  }
  return(result)
}

#' Returns metadata for a file
get.metadata <- function(path) {
  path <- normalizePath(path)
  info <- file.info(path)
  list(
    access_time = Sys.time(), # "2020-06-04 07:51:54 PDT"
    last_modified = info$mtime, # "2020-05-20 15:39:13 PDT"
    # TODO:
    # owner? info$uname exists but is NA because we're in a container
    # md5?
    path = path
    )
}

# methods we hijack
# TODO: this fails if library(ihme.covid) occurs *before* any method we spy on
#       it also fails if something is otherwise attached *after* library(ihme.covid) (no known cases of this)
#
# The best solution would look something like this in ihme.covid's .onLoad() method
# * identify each library/package/namespace we wish to spy on
# * define a function to spy on the method(s) from that package after it is attached
# * scan all loaded namespaces
# * for each package we want to spy on:
#   * if it is attached, call the appropriate spy function
#   * if it is NOT attached, set an event to call the appropriate function during "attach"
#
# NOTE: doing this in .onLoad() means we will be doing this explicitly instead
# of implicitly by simply being earlier on the search path. It also removes the
# need to explicitly call library(ihme.covid). It would, however, still require
# that some ihme.covid:: call occurred before any I/O happened. This is *maybe*
# acceptable as we can set the covid-19 R template to call
# ihme.covid::get_script_dir() or ihme.covid::get_output_dir() very early in
# the code (which logically makes sense)
#
# NOTE: By my reading I believe *attach* is the only event we care about
# because packages that are only loaded are not on the search path because
# packages that are only loaded are not on the search path and thus can't be accessed via `fread` but instead only by `data.table::fread`
#
# NOTE: the fullest solution would be to actually take over the namespaces
# using assignInNamespace. However this is a more complicated solution and may
# introduce other issues, and probably is irrelevant as I don't think anyone
# *ever* uses namespaced calls in the covariate code except where Mike adds them.
#
# Docs for hooks including order of operations, .onLoad, "onLoad" hooks, and "attach" hook
# https://stat.ethz.ch/R-manual/R-patched/library/base/html/userhooks.html
#
# attach vs onLoad events
# https://stackoverflow.com/a/56538266
#
# assigning to other package namespaces
# https://stackoverflow.com/a/58238931
fread <- function(path, ...) {
  tryCatch({
    md <- get.metadata(path)
    md$call <- "fread"
    .append.input.file(md)
  },
  error = function(e) {
    message(sprintf("Errored recording metdata for %s - YOU ARE LACKING PROVENANCE", path))
  }, finally = {
    result <- data.table::fread(path, ...)
  })
  return(result)
}

read.csv <- function(path, ...) {
  tryCatch({
    md <- get.metadata(path)
    md$call <- "read.csv"
    .append.input.file(md)
  },
  error = function(e) {
    message(sprintf("Errored recording metdata for %s - YOU ARE LACKING PROVENANCE", path))
  }, finally = {
    result <- utils::read.csv(path, ...)
  })
  return(result)
}
