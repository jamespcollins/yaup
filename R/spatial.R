#' Non-destructive X-Y coordinates to sf point
#'
#' Converts tabular coordinates into SF points while preserving the
#' coordinate columns in the target data.
#' @param data Tibble that includes lat-long coordinate pairs.
#' @param lon Longitude column name, without quotes.
#' @param lat Latitude column name, without quotes.
#' @param target_crs SF CRS id to set. Default is 4326, which is
#' returned by many geocding services.
#' @return The input tibble as SF object with geometry column.
#' @export

xy_to_point <- function(data, lon, lat, target_crs = NULL) {
  if (is.null(target_crs)) {
    target_crs = 4326
    warning('No target_crs specified. Using EPSG:4326 default.')
  }

  data |>
    dplyr::mutate(
      lat_consume = {{ lat }},
      lon_consume = {{ lon }}
    ) |>
    sf::st_as_sf(coords = c('lon_consume', 'lat_consume')) |>
    sf::st_set_crs(target_crs)
}
