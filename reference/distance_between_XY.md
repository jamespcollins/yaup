# Distance between coordinates

Initially from 04a_911_compare.R

## Usage

``` r
distance_between_XY(
  data,
  a.lon_x,
  a.lat_y,
  b.lon_x,
  b.lat_y,
  dist_col = "dist",
  drop_units = TRUE,
  target_crs = 4326
)
```

## Arguments

- data:

  sf data frame like object.

- a.lon_x:

  Column name of first coordinate longitude.

- a.lat_y:

  Column name of first coordinate latitude.

- b.lon_x:

  Column name of second coordinate longitude.

- b.lat_y:

  Column name of second coordinate latitude.

- dist_col:

  Column name in which to store calculated distance.

- drop_units:

  Column name of second coordinate latitude.

- target_crs:

  CRS to use for calculation. Defaults to 4326 (WGS84).

## Value

Input data with `dist_col` appended.
