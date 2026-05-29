# Geocode with ArcGIS GeocodeServer

Passess address vector to a ArcGIS GeocodeServer endpoint.

## Usage

``` r
geocode_with_geocodeServer(addresses, geocode_url, crs = 4326)
```

## Arguments

- addresses:

  Vector of single-line address strings to geocode.

- geocode_url:

  Full URL of ArcGIS GeocodeServer endpoint. Should end with
  `GeocodeServer/findAddressCandidates`.

- crs:

  CRS geocoder should output. Defaults to 4326 (WGS84).

## Value

Data frame with `input_address`, `candidate_address`, `lat`, `lon`, and
`score` columns

## Examples

``` r
if (FALSE) { # \dontrun{
# Geocode a vector of addresses with the NC OneMap GeocodeServer
address_vector = c('123 EASY STREET, RALEIGH, NC')
geocode_result <- geocode_with_geocodeServer(
 addresses_vector,
 'https://services.nconemap.gov/secure/rest/services/AddressNC/AddressNC_geocoder/GeocodeServer/findAddressCandidates'
) |> tibble::tibble()
} # }
```
