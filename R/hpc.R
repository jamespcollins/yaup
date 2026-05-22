#' Check if the script is run via R CMD BATCH
#'
#' Checks if script is run via R CMD BATCH by looking for --file or -f argument.
#' @return Logical
#' @export

is_batch <- function() {
  args <- commandArgs(trailingOnly = FALSE)
  any(grepl("^--file=", args)) ||
    any(grepl("^-f", args)) ||
    length(grep("Rscript", args)) > 0
}

#' Throw error if not run via R CMD BATCH
#'
#' Checks if script is run via R CMD BATCH by looking for --file or -f argument.
#' @return Logical
#' @export

require_batch <- function() {
  if (!is_batch()) {
    stop(simpleError('This must be executed in a batch session.'))
  }
}
