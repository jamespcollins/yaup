sample_data = tibble::tribble(
  ~ID , ~start                       , ~end                         ,
    1 , lubridate::ymd('2026-01-01') , lubridate::ymd('2026-01-31') ,
    2 , lubridate::ymd('2026-01-01') , lubridate::ymd('2027-01-01') ,
)

test_that('date_replicate_range() works correctly', {
  sample_data |>
    date_replicate_range(
      start,
      end,
      dest,
      'day'
    ) |>
    dplyr::count(ID) |>
    as.list() |>
    expect_equal(list(
      ID = c(1, 2),
      n = c(31, 366)
    ))

  sample_data |>
    date_replicate_range(
      start,
      end,
      dest,
      'week'
    ) |>
    dplyr::count(ID) |>
    as.list() |>
    expect_equal(list(
      ID = c(1, 2),
      n = c(5, 53)
    ))

  sample_data |>
    date_replicate_range(
      start,
      end,
      dest,
      'month'
    ) |>
    dplyr::count(ID) |>
    as.list() |>
    expect_equal(list(
      ID = c(1, 2),
      n = c(1, 13)
    ))

  sample_data |>
    date_replicate_range(
      start,
      end,
      dest,
      'year'
    ) |>
    dplyr::count(ID) |>
    as.list() |>
    expect_equal(list(
      ID = c(1, 2),
      n = c(1, 2)
    ))
})
