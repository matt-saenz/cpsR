

#' Load CPS ASEC microdata from the Census API
#'
#' \code{get_asec()} loads
#' \href{https://www.census.gov/data/datasets/time-series/demo/cps/cps-asec.html}{CPS ASEC}
#' microdata from the Census API.
#'
#' @param year Year of data to retrieve.
#' @param vars Character vector of variables to retrieve, where each vector
#'   element corresponds to the name of a single variable. Variable names can
#'   be given in uppercase or lowercase but are always made lowercase in the
#'   returned data.
#' @param key \href{https://api.census.gov/data/key_signup.html}{Census API key}.
#'   Defaults to environment variable \code{CENSUS_API_KEY}.
#' @param show_url If \code{TRUE}, show the URL the request was sent to
#'   (with \code{key} suppressed). Defaults to \code{FALSE}.
#' @param tibble If \code{TRUE} (default), return data as a
#'   \href{https://tibble.tidyverse.org}{tibble}. If \code{FALSE}, return data
#'   as a base data frame.
#' @return A tibble or base data frame.
#'
#' @export
get_asec <- function(year, vars, key = get_key(),
                     show_url = FALSE, tibble = TRUE) {

  # Check args -----------------------------------------------------------------

  check_key(key)
  check_year(year, dataset = "asec")
  vars <- format_vars(vars)

  # Get data -------------------------------------------------------------------

  url <- httr::modify_url(
    url = "https://api.census.gov",
    path = paste0("data/", year, "/cps/asec/mar"),
    query = list(get = vars, key = key)
  )

  message("Getting CPS ASEC microdata for ", year)
  df <- get_data(url = url, show_url = show_url, tibble = tibble)

  # Return data ----------------------------------------------------------------

  df
}


#' Load basic monthly CPS microdata from the Census API
#'
#' \code{get_basic()} loads
#' \href{https://www.census.gov/data/datasets/time-series/demo/cps/cps-basic.html}{basic monthly CPS}
#' microdata from the Census API.
#'
#' @param month Month of data to retrieve (specified as a number).
#' @inheritParams get_asec
#' @return A tibble or base data frame.
#'
#' @export
get_basic <- function(year, month, vars, key = get_key(),
                      show_url = FALSE, tibble = TRUE) {

  # Check args -----------------------------------------------------------------

  check_key(key)
  check_year(year, dataset = "basic")

  if (!is_number(month) || month %!in% 1:12) {
    stop("`month` must be a number ranging from 1 to 12", call. = FALSE)
  }

  vars <- format_vars(vars)

  # Get data -------------------------------------------------------------------

  month_abb <- tolower(month.abb)[month] # Format for Census API
  month_name <- month.name[month] # Format for message

  url <- httr::modify_url(
    url = "https://api.census.gov",
    path = paste0("data/", year, "/cps/basic/", month_abb),
    query = list(get = vars, key = key)
  )

  message(paste("Getting basic monthly CPS microdata for", month_name, year))
  df <- get_data(url = url, show_url = show_url, tibble = tibble)

  # Return data ----------------------------------------------------------------

  df
}


get_data <- function(url, show_url, tibble) {
  if (show_url) {
    message("URL: ", sub(pattern = "&key=.*", replacement = "", x = url))
  }

  # Send request ---------------------------------------------------------------

  resp <- httr::GET(url)

  # Check response -------------------------------------------------------------

  if (resp$status_code != 200) {
    status <- httr::http_status(resp)

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
  df <- as.data.frame(cols, stringsAsFactors = FALSE) # All columns are character vectors
  names(df) <- tolower(col_names)

  # Coerce columns to numeric when safe

  for (i in seq_along(df)) {
    col <- df[[i]]

    na_before <- sum(is.na(col))
    numeric_col <- suppressWarnings(as.numeric(col))
    na_after <- sum(is.na(numeric_col))

    if (na_after == na_before) {
      df[[i]] <- numeric_col
    }
  }

  # Return data frame ----------------------------------------------------------

  if (tibble) {
    df <- tibble::as_tibble(df)
  }

  df
}
