

#' Load CPS ASEC microdata
#'
#' \code{get_asec()} loads
#' \href{https://www.census.gov/data/datasets/time-series/demo/cps/cps-asec.html}{CPS ASEC}
#' microdata using the Census API.
#'
#' @param year Year of data to retrieve. Years 2014 to 2022 are currently
#'   supported.
#' @param vars Character vector of variables to retrieve, where each vector
#'   element corresponds to the name of a single variable. Variable names can
#'   be given in uppercase or lowercase but are always made lowercase in the
#'   returned data.
#' @param key \href{https://api.census.gov/data/key_signup.html}{Census API key}.
#'   Defaults to environment variable \code{CENSUS_API_KEY}. See the
#'   \href{https://github.com/matt-saenz/cpsR#census-api-key}{README} for info
#'   on how (and why) to set up env var \code{CENSUS_API_KEY}.
#' @param show_url If \code{TRUE}, show the URL the request was sent to
#'   (with \code{key} suppressed). Defaults to \code{FALSE}.
#' @param tibble If \code{TRUE} (default), return data as a
#'   \href{https://tibble.tidyverse.org}{tibble}. If \code{FALSE}, return data
#'   as a base data frame.
#' @param convert If \code{TRUE} (default), run
#'   \code{\link[utils:type.convert]{type.convert()}} with \code{as.is = TRUE}
#'   on the data returned by the Census API. If \code{FALSE}, all columns in
#'   the returned data will be character vectors (exactly as returned by the
#'   Census API).
#' @return A \href{https://tibble.tidyverse.org}{tibble} or base data frame.
#' @examples
#' \dontrun{
#' asec21 <- get_asec(2021, vars = c("marsupwt", "spm_poor"))
#' }
#'
#' @export
get_asec <- function(year, vars, key = get_key(),
                     show_url = FALSE, tibble = TRUE, convert = TRUE) {

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

  df <- get_data(
    url = url,
    show_url = show_url,
    tibble = tibble,
    convert = convert
  )

  # Return data ----------------------------------------------------------------

  df
}


#' Load basic monthly CPS microdata
#'
#' \code{get_basic()} loads
#' \href{https://www.census.gov/data/datasets/time-series/demo/cps/cps-basic.html}{basic monthly CPS}
#' microdata using the Census API.
#'
#' @param year Year of data to retrieve. Years 1989 to 2022 are currently
#'   supported.
#' @param month Month of data to retrieve (specified as a number).
#' @inherit get_asec params return
#' @examples
#' \dontrun{
#' sep21 <- get_basic(
#'   year = 2021,
#'   month = 9,
#'   vars = c("pwcmpwgt", "prpertyp", "prtage", "pemlr")
#' )
#' }
#'
#' @export
get_basic <- function(year, month, vars, key = get_key(),
                      show_url = FALSE, tibble = TRUE, convert = TRUE) {

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

  df <- get_data(
    url = url,
    show_url = show_url,
    tibble = tibble,
    convert = convert
  )

  # Return data ----------------------------------------------------------------

  df
}


get_data <- function(url, show_url, tibble, convert) {
  if (show_url) {
    message("URL: ", sub(pattern = "&key=.*", replacement = "", x = url))
  }

  # Send request ---------------------------------------------------------------

  ua <- httr::user_agent("https://github.com/matt-saenz/cpsR")
  resp <- httr::GET(url, ua)

  # Check response -------------------------------------------------------------

  status_code <- resp$status_code

  if (status_code != 200) {
    status <- httr::http_status(resp)

    stop(
      "Census API request failed [", status_code, "]: ", status$reason,
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
  names(df) <- tolower(col_names) # Column names are always made lowercase

  if (convert) {
    df <- utils::type.convert(df, as.is = TRUE)
  }

  if (tibble) {
    df <- tibble::as_tibble(df)
  }

  # Return data frame ----------------------------------------------------------

  df
}
