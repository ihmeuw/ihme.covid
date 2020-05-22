#' Convenience function for printing information
#'
#' Provide any number of arguments which are the variables you want printed
#' Note that this function must be called directly and not wrapped in e.g., capture.output
#'
#' @param ... variables to debug. Provide by name.
#'
#' @examples
#' \dontrun{
#' foo <- 7
#' bar <- 9
#' print_debug(foo, bar)
#' }
print_debug <- function(...) {
  # convert "..." to the symbols used (e.g., what was typed as the function args)
  symbols <- eval(substitute(alist(...)))
  for (symbol in symbols) {
    name <- deparse(symbol)
    val <- tryCatch(
      # get actual value from the parent environment, which is where it is *assumed* this was called from
      # note that nested calls will break this logic so e.g., capture.output(print_debug(foo)) does not work
      eval(symbol, envir = parent.frame())
      , error = function(e) {
        sprintf("ERROR - no %s defined", name)
      }
    )
    # special logic for handling non-scalar values
    if (is.null(val)) {
      val <- "NULL"
    } else if (length(val) > 1) {
      if (is.character(val)) {
        val <- sprintf("c('%s')", paste(val, collapse = "', '"))
      } else {
        val <- sprintf("c(%s)", toString(val))
      }
    }
    message(sprintf("%s: %s", name, val))
  }
}
