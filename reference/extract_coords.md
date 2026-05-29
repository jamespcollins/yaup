# Extract centroid coordinates to columns

Adds centroid lat and long coordinates as new columns.

## Usage

``` r
extract_coords(
  data,
  lat_to = "lat",
  lon_to = "lon",
  centroid = FALSE,
  drop_geometry = FALSE
)
```

## Arguments

- data:

  sf data frame like object.

- lat_to:

  Latitude column name, with quotes.

- lon_to:

  Longitude column name, with quotes.

- centroid:

  Convert the data to centroids first. Defaults to FALSE.

- drop_geometry:

  Drop the sf geometry. Defaults to FALSE.

## Value

The input object with new lat and lon columns.
