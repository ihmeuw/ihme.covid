# Not exported. Tracks input files used for those functions we track
# Global state for our package, but not globally available
.input.files <- list()

.append.input.file <- function(metadata) {
  # TODO: check for duplicates in case e.g., someone re-ran something because it crashed midway
  .input.files[[length(.input.files) + 1]] <- metadata
  # we need to re-assign this due to how the package value (which is not a global value) is managed by R
  assignInNamespace(".input.files", .input.files, ns = "ihme.covid")
}

get.input.files <- function(clear = FALSE) {
  result <- .input.files
  if (clear) {
    assignInNamespace(".input.files", list(), ns = "ihme.covid")
  }
  return(result)
}

#' Returns metadata for a file
.get.metadata <- function(path) {
  list(
    details = "coming soon",
    # TODO:
    # timestamp (runtime)
    # last modified
    # owner?
    # md5?
    path = path
    )
}

# methods we hijack
fread <- function(path, ...) {
  tryCatch({
    md <- .get.metadata(path)
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
    md <- .get.metadata(path)
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
