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
  result <- list(
    access_time = .format.metadata.date(Sys.time()),
    last_modified = .format.metadata.date(info$mtime),
    # TODO:
    # owner? info$uname exists but is NA because we're in a container
    # md5?
    path = path
  )

  # since we know there's only 1 input, unlist result. then get last element
  ext <- utils::tail(
    unlist(strsplit(path, ".", fixed = TRUE)),
    1)

  if (ext == "shp") {
    result$extra <- .get.shp.metadata(path)
  }

  return(result)
}

.format.metadata.date <- function(datelike) {
  as.character(datelike) # TODO: other requests?
}

#' Return extra metadata associated with .shp file
#'
#' A "shapefile" is actually a collection of files. At minimum .shp, .shpx, and .dbf
#'
#' In addition, there are at least 13 optional files that may be included.
#'
#' https://en.wikipedia.org/wiki/Shapefile#Overview
.get.shp.metadata <- function(path) {
  # NOTE: we're being lazy and just grabbing everything that has the same prefix.

  # split on "."; unlist the result into a vector; take all but the last element, re-join with "."
  base <- paste(head(unlist(strsplit(path, ".", fixed = TRUE)), n = -1), collapse = ".")
  # list files in directory which start with the filename (without extension)
  related <- list.files(dirname(base), full.names = TRUE, pattern = basename(base))

  result <- list()
  for (rel in related) {
    info <- file.info(rel)
    result[[basename(rel)]] <- .format.metadata.date(info$mtime)
  }
  return(result)
}

# methods we hijack
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
.spy.on.methods <- function() {
  attached.packages <- .packages()

  pkg.watch <- list(
    "data.table" = "fread",
    "maptools" = "readShapePoly",
    "utils" = "read.csv"
  )

  for (pkg in names(pkg.watch)) {
    methods <- pkg.watch[[pkg]]

    if (pkg %in% attached.packages) {
      # replace now
      .replace.methods.with.spy(methods)
    } else {
      # replace them right after they're loaded
      setHook(
        packageEvent(pkg, "attach"),
        # parameters included for reader comprehension - we don't need or use them
        function(pkg.name, pkg.path) {
          # WARNING: you cannot use `methods` here. The reason is the value is
          # mutated within this loop and R's lazy evaluation means that ALL
          # hook functions will end up having a `methods` value from the final
          # iteration of the loop
          .replace.methods.with.spy(pkg.watch[[pkg.name]])
        },
        action = "append"
      )
    }
  }
}

#' Replace methods in global namespace with the spying methods defined below
.replace.methods.with.spy <- function(methods) {
  # NOTE: google searches reveal that questions and answers are sadly conflating some terms
  # as.environment("package:PKGNAME") returns a namespace of exported values
  # getNamespace("PKGNAME") returns a namespace of all package contents
  this.ns <- getNamespace(packageName())
  for (method in methods) {
    spy.method <- get(sprintf(".spy.on.%s", method), env = this.ns)
    assign(method, spy.method, envir = globalenv())
  }
}


.spy.on.fread <- function(path, ...) {
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

.spy.on.read.csv <- function(path, ...) {
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

.spy.on.readShapePoly <- function(path, ...) {
  tryCatch({
    md <- get.metadata(path)
    md$call <- "readShapePoly"
    .append.input.file(md)
  },
  error = function(e) {
    message(sprintf("Errored recording metdata for %s - YOU ARE LACKING PROVENANCE", path))
  }, finally = {
    return(maptools::readShapePoly(path, ...))
  })
}
