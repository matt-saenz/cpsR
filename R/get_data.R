

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

  message("Getting CPS ASEC microdata for ", year)
  df <- get_data(url, show_url = show_url)

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

  # Get data -------------------------------------------------------------------

  month_abb <- tolower(month.abb)[month] # Format for Census API
  month_name <- month.name[month] # Format for message

  url <- httr::modify_url(
    url = "https://api.census.gov",
    path = glue::glue("data/{year}/cps/basic/{month_abb}"),
    query = list(get = vars, key = key)
  )

  msg <- paste("Getting basic monthly CPS microdata for", month_name, year)
  message(msg)

  df <- get_data(url, show_url = show_url)

  # Return data ----------------------------------------------------------------

  if (tibble) {
    tibble::as_tibble(df)
  } else {
    df
  }
}


get_data <- function(url, show_url) {
  if (show_url) {
    message("URL: ", sub(pattern = "&key=.*", replacement = "", x = url))
  }

  # Send request ---------------------------------------------------------------

  resp <- httr::GET(url)

  # Check response -------------------------------------------------------------

  status <- httr::http_status(resp)

  if (resp$status_code != 200) {
    stop(
      "Census API request failed [", resp$status_code, "]: ", status$reason,
      call. = FALSE
    )
  }

  if (httr::http_type(resp) != "application/json") {
    stop("Census API did not return JSON", call. = FALSE)
  }

  # Parse response -------------------------------------------------------------

  mat <- jsonlite::fromJSON(httr::content(resp, as = "text"))

  if (!is.matrix(mat) || !is.character(mat)) {
    stop("Census API data not parsed as expected", call. = FALSE)
  }

  # Make data frame ------------------------------------------------------------

  col_names <- mat[1, , drop = TRUE] # Character vector of column names
  cols <- mat[-1, , drop = FALSE] # Character matrix of columns
  df <- as.data.frame(cols) # All columns are character vectors
  names(df) <- tolower(col_names)

  # Coerce columns to numeric when safe

  for (i in seq_along(df)) {
    na_before <- sum(is.na(df[[i]]))
    numeric_col <- suppressWarnings(as.numeric(df[[i]]))
    na_after <- sum(is.na(numeric_col))
    if (na_after == na_before) {
      df[[i]] <- numeric_col
    }
  }

  # Return data frame ----------------------------------------------------------

  df
}
