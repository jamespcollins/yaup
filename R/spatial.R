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

#' Extract centroid coordinates to columns
#'
#' Adds centroid lat and long coordinates as new columns.
#' @param data sf data frame like object.
#' @param lat_to Latitude column name, with quotes.
#' @param lon_to Longitude column name, with quotes.
#' @param centroid Convert the data to centroids first. Defaults to FALSE.
#' @param drop_geometry Drop the sf geometry. Defaults to FALSE.
#' @return The input object with new lat and lon columns.
#' @export

extract_coords = function(
  data,
  lat_to = 'lat',
  lon_to = 'lon',
  centroid = FALSE,
  drop_geometry = FALSE
) {
  stopifnot(inherits(data, 'sf'))
  stopifnot(!lat_to %in% names(data))
  stopifnot(!lon_to %in% names(data))

  if (centroid) {
    data = sf::st_centroid(data)
  }

  res = data %>%
    dplyr::mutate(
      {{ lat_to }} := sf::st_coordinates(.)[, 2],
      {{ lon_to }} := sf::st_coordinates(.)[, 1]
    )

  if (drop_geometry) {
    res |> sf::st_drop_geometry()
  } else {
    res
  }
}

#' Geocode with ArcGIS GeocodeServer
#'
#' Passess address vector to a ArcGIS GeocodeServer endpoint.
#' @param addresses Vector of single-line address strings to geocode.
#' @param geocode_url Full URL of ArcGIS GeocodeServer endpoint.
#' Should end with `GeocodeServer/findAddressCandidates`.
#' @param crs CRS geocoder should output. Defaults to 4326 (WGS84).
#' @return Data frame with `input_address`, `candidate_address`, `lat`, `lon`,
#' and `score` columns
#' @export
#' @keywords geocode
#' @examples
#' \dontrun{
#' # Geocode a vector of addresses with the NC OneMap GeocodeServer
#' address_vector = c('123 EASY STREET, RALEIGH, NC')
#' geocode_result <- geocode_with_geocodeServer(
#'  addresses_vector,
#'  'https://services.nconemap.gov/secure/rest/services/AddressNC/AddressNC_geocoder/GeocodeServer/findAddressCandidates'
#' ) |> tibble::tibble()
#' }

geocode_with_geocodeServer <- function(
  addresses,
  geocode_url,
  crs = 4326
) {
  # Initialize an empty dataframe for results
  results <- data.frame()

  i = 1
  for (address in unique(addresses)) {
    writeLines(paste0(i, "/", length(addresses), " - ", address))

    # Create the request URL
    request_url = paste0(
      geocode_url,
      "?f=json&outSR=",
      crs,
      "&singleLine=",
      utils::URLencode(address)
    )

    # Make the GET request
    response <- httr::GET(request_url)

    # Check if the request was successful
    if (httr::status_code(response) == 200) {
      # Parse the JSON response
      json_response <- jsonlite::fromJSON(httr::content(response, "text"))

      # Extract relevant information
      if (length(json_response$candidates) > 0) {
        candidate <- json_response$candidates[1, ]
        results <- rbind(
          results,
          data.frame(
            input_address = address,
            candidate_address = candidate$address,
            lat = candidate$location$y,
            lon = candidate$location$x,
            score = candidate$score
          )
        )
      } else {
        results <- rbind(
          results,
          data.frame(
            input_address = address,
            candidate_address = NA,
            lat = NA,
            lon = NA,
            score = NA
          )
        )
      }
    } else {
      warning(paste("Failed to geocode address:", address))
    }

    i = i + 1
  }

  return(results)
}

#' Geocode with ArcGIS GeocodeServer and return multiple candidate
#'
#' Passess address vector to a ArcGIS GeocodeServer endpoint. Returns multiple
#' candidates for an input row when available.
#' @param data Data frame-like object containing columns with addresses, city
#' names, and stae names.
#' @param address_col Column name containing street addresses.
#' @param city_col Column name containing city names.
#' @param state_col Column name containing state names.
#' @param geocode_url Full URL of ArcGIS GeocodeServer endpoint. Should end
#' with `GeocodeServer/findAddressCandidates`.
#' @param id_col Column name containing unique identifiers. Defaults to
#' `row_id`.
#' @param crs CRS geocoder should output. Defaults to 4326 (WGS84).
#' @param prefix Prefix for geocoder result columns. Defaults to `gc.`.
#' @return Tibble with geocode results.
#' @export
#' @keywords geocode
#' @examples
#' \dontrun{
#' # Geocode a vector of addresses with the NC OneMap GeocodeServer
#' addresses = tibble::tibble(
#'  row_id = c(1),
#'  address = c('123 EASY STREET'),
#'  city = c('RALEIGH'),
#'  state = c('NC')
#' )
#'
#' geocode_result <- addresses |>
#'  geocode_with_geocodeServer(
#'    address,
#'    city,
#'    state,
#'    'https://services.nconemap.gov/secure/rest/services/AddressNC/AddressNC_geocoder/GeocodeServer/findAddressCandidates'
#'  )
#' }

geocode_with_geocodeServer_multiCandidate <- function(
  data,
  address_col,
  city_col,
  state_col,
  geocode_url,
  id_col = 'row_id',
  crs = 4326,
  prefix = 'gc.'
) {
  results <- tibble::tibble()

  data <- data %>%
    # make request URLS
    dplyr::mutate(
      request_url = paste0(
        geocode_url,
        "?f=json&outSR=",
        crs,
        "&address=",
        utils::URLencode(!!rlang::sym(address_col)),
        "&city=",
        utils::URLencode(!!rlang::sym(city_col)),
        "&region=",
        utils::URLencode(!!rlang::sym(state_col)),
        "&outFields=*"
      )
    )

  for (row_num in 1:nrow(data)) {
    row_id <- as.integer(data[row_num, {{ id_col }}])

    writeLines(paste0(
      row_num,
      "/",
      nrow(data),
      " - ",
      data[row_num, {{ address_col }}],
      ', ',
      data[row_num, {{ city_col }}],
      ', ',
      data[row_num, {{ state_col }}]
    ))

    # Make the GET request
    response <- httr::GET(as.character(data[row_num, 'request_url']))

    # Check if the request was successful
    if (httr::status_code(response) != 200) {
      warning(paste("Failed to geocode address"))
      next
    }

    # Parse the JSON response
    json_response <- jsonlite::fromJSON(content(response, "text"))

    candidates <- tibble::as_tibble(json_response$candidates)

    # check candidates returned
    if (nrow(candidates) == 0) {
      warning(paste("No candidates"))
      next
    }

    # check they have attributes
    if (length(candidates$attributes) == 0) {
      warning(paste(
        nrow(candidates),
        'candidate(s), but no attributes'
      ))
      next
    }

    point_addresses <- candidates %>%
      dplyr::filter(
        attributes$Addr_type %in%
          c('PointAddress', 'Subaddress')
      )

    writeLines(paste(
      nrow(point_addresses),
      'point/sub address(es).'
    ))

    point_addresses_unnest <- point_addresses |>
      # unnest results
      tidyr::unnest(cols = c(location, attributes)) |>
      # keep/rename relevant cols
      dplyr::select(
        address:score,
        street_number = AddNum,
        street_name = StName,
        city = City,
        county = Subregion,
        state = Region,
        zip = Postal
      ) %>%
      # add candidate count and id
      dplyr::mutate(
        n_candidates = nrow(point_addresses),
        {{ id_col }} := row_id
      )

    # add to results
    results <- dplyr::bind_rows(
      results,
      point_addresses_unnest
    )
  }

  # rejoin results to data
  data <- dplyr::left_join(
    data,
    results |>
      dplyr::rename_at(dplyr::vars(address:n_candidates), ~ paste0(prefix, .)),
    by = id_col
  ) %>%
    tidyr::replace_na(list(gc.n_candidates = 0))

  return(data)
}
