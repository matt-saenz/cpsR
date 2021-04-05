

#' Load CPS ASEC microdata from the Census API
#'
#' \code{get_asec()} loads
#' \href{https://www.census.gov/data/datasets/time-series/demo/cps/cps-asec.html}{CPS ASEC}
#' microdata from the Census API.
#'
#' @param vars Character vector of variables to retrieve, where each vector
#'   element corresponds to a single variable.
#' @param year Year of data to retrieve.
#' @param key \href{https://api.census.gov/data/key_signup.html}{Census API key}.
#'   Store in env var \code{CENSUS_API_KEY} to pass automatically.
#' @param show_url If \code{TRUE}, show URL request was sent to
#'   (with \code{key} suppressed). Defaults to \code{FALSE}.
#' @param tibble If \code{TRUE} (default), return data as a tibble. If
#'   \code{FALSE}, return data as a base data frame.
#' @return A tibble or base data frame with requested data.
#'
#' @export
get_asec <- function(vars, year, key = NULL,
                     show_url = FALSE, tibble = TRUE) {

  # Check args -----------------------------------------------------------------

  key <- check_key(key)
  vars <- check_vars(vars)
  check_year(year, dataset = "asec")

  # Get data -------------------------------------------------------------------

  url <- httr::modify_url(
    url = "https://api.census.gov",
    path = glue::glue("data/{year}/cps/asec/mar"),
    query = list(get = vars, key = key)
  )

  df <- get_data(url, show_url = show_url)
  df <- convert_cols(df)

  # Return data ----------------------------------------------------------------

  if (tibble) {
    tibble::as_tibble(df)
  } else {
    df
  }
}


#' Load basic monthly CPS microdata from the Census API
#'
#' \code{get_basic()} loads
#' \href{https://www.census.gov/data/datasets/time-series/demo/cps/cps-basic.html}{basic monthly CPS}
#' microdata from the Census API.
#'
#' @param month Month of data to retrieve (specified as a number).
#' @inheritParams get_asec
#' @return A tibble or base data frame with requested data.
#'
#' @export
get_basic <- function(vars, year, month, key = NULL,
                      show_url = FALSE, tibble = TRUE) {

  # Check args -----------------------------------------------------------------

  key <- check_key(key)
  vars <- check_vars(vars)
  check_year(year, dataset = "basic")

  if (length(month) != 1 || !is.numeric(month) || !(month %in% 1:12)) {
    stop("Pass one `month` at a time as a number", call. = FALSE)
  }

  month <- tolower(month.abb)[month] # Format for Census API

  # Get data -------------------------------------------------------------------

  url <- httr::modify_url(
    url = "https://api.census.gov",
    path = glue::glue("data/{year}/cps/basic/{month}"),
    query = list(get = vars, key = key)
  )

  df <- get_data(url, show_url = show_url)
  df <- convert_cols(df)

  # Return data ----------------------------------------------------------------

  if (tibble) {
    tibble::as_tibble(df)
  } else {
    df
  }
}
