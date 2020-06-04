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
