# Replicate rows across date range

Creates a new row for each interval within a date range.

## Usage

``` r
date_replicate_range(
  data,
  start_date_col,
  end_date_col,
  dest_date_col,
  interval
)
```

## Arguments

- data:

  Table.

- start_date_col:

  Date column of start date.

- end_date_col:

  Date column of end date.

- dest_date_col:

  Date column to write replicate date.

- interval:

  Interval to replicate over. Must be in 'day', 'week', 'month', 'year'.

## Value

Table of replicated rows with all original columns.

## Examples

``` r
if (FALSE) { # \dontrun{
 tibble::tribble(
 ~ID , ~start                       , ~end                         ,
   1 , lubridate::ymd('2026-01-01') , lubridate::ymd('2026-01-31') ,
   2 , lubridate::ymd('2026-01-01') , lubridate::ymd('2027-01-01') ,
 ) %>%
 replicate_date_range(
   start,
   end,
   dest,
   'day'
 )
} # }
```
