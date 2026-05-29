# Geocode with ArcGIS GeocodeServer and return multiple candidate

Passess address vector to a ArcGIS GeocodeServer endpoint. Returns
multiple candidates for an input row when available.

## Usage

``` r
geocode_with_geocodeServer_multiCandidate(
  data,
  address_col,
  city_col,
  state_col,
  geocode_url,
  id_col = "row_id",
  crs = 4326,
  prefix = "gc."
)
```

## Arguments

- data:

  Data frame-like object containing columns with addresses, city names,
  and stae names.

- address_col:

  Column name containing street addresses.

- city_col:

  Column name containing city names.

- state_col:

  Column name containing state names.

- geocode_url:

  Full URL of ArcGIS GeocodeServer endpoint. Should end with
  `GeocodeServer/findAddressCandidates`.

- id_col:

  Column name containing unique identifiers. Defaults to `row_id`.

- crs:

  CRS geocoder should output. Defaults to 4326 (WGS84).

- prefix:

  Prefix for geocoder result columns. Defaults to `gc.`.

## Value

Tibble with geocode results.

## Examples

``` r
if (FALSE) { # \dontrun{
# Geocode a vector of addresses with the NC OneMap GeocodeServer
addresses = tibble::tibble(
 row_id = c(1),
 address = c('123 EASY STREET'),
 city = c('RALEIGH'),
 state = c('NC')
)

geocode_result <- addresses |>
 geocode_with_geocodeServer(
   address,
   city,
   state,
   'https://services.nconemap.gov/secure/rest/services/AddressNC/AddressNC_geocoder/GeocodeServer/findAddressCandidates'
 )
} # }
```
