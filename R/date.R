#' Replicate rows across date range
#'
#' Creates a new row for each interval within a date range.
#' @param data Table.
#' @param start_date_col Date column of start date.
#' @param end_date_col Date column of end date.
#' @param dest_date_col Date column to write replicate date.
#' @param interval Interval to replicate over. Must be in 'day', 'week', 'month', 'year'.
#' @return Table of replicated rows with all original columns.
#' @export
#' @examples
#' \dontrun{
#'  tibble::tribble(
#'  ~ID , ~start                       , ~end                         ,
#'    1 , lubridate::ymd('2026-01-01') , lubridate::ymd('2026-01-31') ,
#'    2 , lubridate::ymd('2026-01-01') , lubridate::ymd('2027-01-01') ,
#'  ) %>%
#'  replicate_date_range(
#'    start,
#'    end,
#'    dest,
#'    'day'
#'  )
#' }

date_replicate_range = function(
  data,
  start_date_col,
  end_date_col,
  dest_date_col,
  interval
) {
  stopifnot(interval %in% c('day', 'week', 'month', 'year'))

  data |>
    dplyr::mutate(
      {{ dest_date_col }} := purrr::map2(
        {{ start_date_col }},
        {{ end_date_col }},
        seq,
        by = interval
      )
    ) |>
    tidyr::unnest({{ dest_date_col }})
}
