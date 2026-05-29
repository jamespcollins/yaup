#' Confirm before overwriting existing output file with changed data
#'
#' Description
#' @param data Current working data.
#' @param target Target file path. Should end in .rds or .csv.
#' @param force_in_batch If called via an R CMD BATCH job, whether to force overwrite and archive. Default TRUE.
#' @param compress Pass-through parameter to readr::write_rds.
#' @param pass_data If successful, return the supplied data for further action.
#' Default true.
#' @param archive If user chooses to overwrite file, rename existing file as
#' archival copy. Default NULL prompts for action.
#' @param rds_dir The directory to store RDS representations of CSVs.
#' @param use_here Use here::here() to reference to project.
#' @return returns
#' @export
#' @keywords write
#' @examples
#' \dontrun{
#' # Example title
#' }

confirm_overwrite <- function(
  data,
  target,
  force_in_batch = TRUE,
  compress = 'none',
  pass_data = FALSE,
  archive = NULL,
  rds_dir = '.csv_overwrites',
  use_here = TRUE
) {
  if (use_here) {
    target_here = here::here(target)
  } else {
    target_here = target
  }

  writeLines(paste(
    '\n\n#########\nConfirm overwrite for:',
    target
  ))

  intermediate = get_intermediate_rds_store(target, rds_dir)

  dir.create(intermediate$dir, showWarnings = FALSE)

  target_format <- stringr::str_extract(target, '\\.\\w+$')

  IS_CSV = target_format == '.csv'

  # if that file path is not .csv or .rds, return error
  if (!target_format %in% c('.csv', '.rds')) {
    stop(simpleError('Target file path must end with .csv or .rds'))
  }

  # check data is a data frame like object
  if (!'data.frame' %in% class(data)) {
    stop(simpleError('Data must be a data frame or similar object'))
  }

  # if target file does not already exist, just return data
  if (!file.exists(target_here)) {
    # write
    if (IS_CSV) {
      readr::write_csv(data, target_here)
      readr::write_rds(data, intermediate$path, compress = compress)
    } else {
      readr::write_rds(data, target_here, compress = compress)
    }

    writeLines(paste(
      'No existing file at target path. Wrote',
      nrow(data),
      'rows to',
      target
    ))
  } else {
    # read target
    if (IS_CSV) {
      target_data = readr::read_rds(intermediate$path)
    } else {
      target_data = readr::read_rds(target_here)
    }

    # check if identical
    if (identical(data, target_data)) {
      writeLines(
        'Supplied and existing data at target are identical. No action.'
      )
    } else {
      if (is_batch() & force_in_batch) {
        continue = 'Y'
      } else if (is_batch() & !force_in_batch) {
        continue = 'N'
      } else {
        # ask if continue
        continue = readline(
          paste(
            'Supplied and existing data at target are NOT identical.\nSupplied:',
            nrow(data),
            '  Target:',
            nrow(target_data),
            '\nTarget last modified:',
            file.info(target)$mtime,
            '\nContinue with write? (Y/N) '
          )
        )
      }

      if (continue == 'Y') {
        writeLines('\nUser overwrote dataset.')

        if (is_batch()) {
          archive = TRUE
        } else if (is.null(archive)) {
          if (readline('\nArchive existing file? (return/N) ') == 'N') {
            archive = FALSE
          } else {
            archive = TRUE
          }
        }

        # make archive of target dataset
        if (archive) {
          archive_path = paste(
            target_here,
            'overwrite',
            lubridate::now(),
            '.archive'
          )
          archive_label = paste(
            target,
            'overwrite',
            lubridate::now(),
            '.archive'
          )
          file.rename(
            from = target_here,
            to = archive_path
          )
          writeLines(paste(
            'Archived previous version as',
            archive_label
          ))
        }

        # write
        if (IS_CSV) {
          readr::write_csv(data, target_here)
          readr::write_rds(
            data,
            intermediate$path,
            compress = compress
          )
        } else {
          readr::write_rds(data, target_here, compress = compress)
        }

        writeLines(paste(
          'Wrote',
          nrow(data),
          'rows to',
          target
        ))
      } else {
        writeLines('User did NOT overwrite dataset.')
        warning(paste('User cancelled overwrite to', target))
      }
    }
  }

  writeLines(
    '#########'
  )

  if (pass_data) {
    return(data)
  }
}

#' Read a CSV path but from intermediate RDS store.
#'
#' Description
#' @param path CSV path to read
#' @param rds_dir The directory to store RDS representations of CSVs.
#' @return Returns data read from RDS store.
#' @export

read_csv_from_intermediate <- function(path, rds_dir = '.csv_overwrites') {
  writeLines(paste(
    '\n\n#########\nReading RDS store for:',
    path
  ))

  # if that file path is not .csv or .rds, return error
  if (stringr::str_extract(path, '\\.\\w+$') != '.csv') {
    stop(simpleError('Target file path must end with .csv'))
  }

  intermediate_target = paste0(
    rds_dir,
    digest::digest(path, algo = 'md5'),
    '.rds'
  )

  if (!file.exists(intermediate_target)) {
    stop(simpleError(paste(
      'No intermediate RDS store at this path:',
      intermediate_target
    )))
  }

  data = readr::read_rds(intermediate_target)

  writeLines(
    '#########'
  )

  return(data)
}


#' Get target dir
#'
#' Description
#' @param target Target file path. Should end in .rds or .csv.
#' @param rds_dir The directory to store RDS representations of CSVs.
#' @return returns

get_intermediate_rds_store <- function(target, rds_dir) {
  if (!grepl('\\/', target)) {
    intermediate_dir = paste0(
      './',
      rds_dir
    )
  } else {
    intermediate_dir = paste0(
      stringr::str_remove(target, '\\/[^\\/]+$'),
      '/',
      rds_dir
    )
  }

  # for CSVs, will create an intermediate RDS for better comparison
  intermediate_target = paste0(
    intermediate_dir,
    '/',
    digest::digest(target, algo = 'md5'),
    '.rds'
  )

  return(list(
    dir = intermediate_dir,
    path = intermediate_target
  ))
}
