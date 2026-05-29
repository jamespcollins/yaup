#' Open a log file
#'
#' Opens a log file connection and creates the file if it does not exist.
#' @param name Name of log file to open or create.
#' @return `log` object to pass to `write_log()`.
#' @export
#' @keywords log

open_log = function(name) {
  LOG_DIR = Sys.getenv('LOG_DIR')

  if (LOG_DIR == '') {
    LOG_DIR = readline(
      'LOG_DIR is not set. Enter project subdirectory for writing logs [default: .logs] '
    )

    if (LOG_DIR == '') {
      LOG_DIR = '.logs'
    }

    if (!file.exists('.Renviron.local')) {
      file.create('.Renviron.local', showWarnings = FALSE)
    }
    write(paste0('LOG_DIR=', LOG_DIR), '.Renviron.local', append = TRUE)

    message(paste0(
      'Wrote LOG_DIR=',
      LOG_DIR,
      ' to .Renviron.local for future sessions.'
    ))

    message(paste0('Added /', LOG_DIR, ' and *.local .gitignore.'))
    if (!file.exists('.gitignore')) {
      file.create('.gitignore', showWarnings = FALSE)
    }
    write(paste0('/', LOG_DIR), '.gitignore', append = TRUE)
    write('*.local', '.gitignore', append = TRUE)

    Sys.setenv(LOG_DIR = LOG_DIR)
  }

  dir.create(here::here(LOG_DIR), showWarnings = FALSE)

  log_path <- here::here(paste0(LOG_DIR, '/', name, '.log'))

  if (!file.exists(log_path)) {
    file.create(log_path)
  }

  log_obj = list(
    name = name,
    path = log_path
  )

  class(log_obj) <- "log"

  log_obj
}

#' Write to a log file
#'
#' Writes a timestamped message to a log file.
#' @param message Message to log.
#' @param log_obj `log` object created with `open_log()`.
#' @param type Log message type. Valid values are `INFO`, `WARN`, and `ERROR`.
#' @return Echos log message to console.
#' @export
#' @keywords log

write_log = function(message, log_obj, type = 'INFO') {
  stopifnot(inherits(log_obj, 'log'))
  stopifnot(type %in% c('INFO', 'WARN', 'ERROR'))

  log_str = paste0(type, '\t', lubridate::now(), '  ', message)

  write(
    log_str,
    log_obj$path,
    append = TRUE
  )

  writeLines(log_str)
}
