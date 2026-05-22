# Non-destructive X-Y coordinates to sf point

Converts tabular coordinates into SF points while preserving the
coordinate columns in the target data.

## Usage

``` r
xy_to_point(data, lon, lat, target_crs = NULL)
```

## Arguments

- data:

  Tibble that includes lat-long coordinate pairs.

- lon:

  Longitude column name, without quotes.

- lat:

  Latitude column name, without quotes.

- target_crs:

  SF CRS id to set. Default is 4326, which is returned by many geocding
  services.

## Value

The input tibble as SF object with geometry column.
