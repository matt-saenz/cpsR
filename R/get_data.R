#' Load CPS ASEC microdata
#'
#' \code{get_asec()} loads
#' \href{https://www.census.gov/data/datasets/time-series/demo/cps/cps-asec.html}{CPS ASEC}
#' microdata using the Census API.
#'
#' @param year Year of data to retrieve. Years 1992 and on are currently
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
  check_key(key)

  check_year(year, min_year = 1992)

  month <- 3 # Month of CPS ASEC is always March

  url <- make_url("asec", year, month, vars, key)

  message("Getting CPS ASEC microdata for ", year)

  df <- get_data(url, show_url, tibble, convert)

  df
}


#' Load basic monthly CPS microdata
#'
#' \code{get_basic()} loads
#' \href{https://www.census.gov/data/datasets/time-series/demo/cps/cps-basic.html}{basic monthly CPS}
#' microdata using the Census API.
#'
#' @param year Year of data to retrieve. Years 1989 and on are currently
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
  check_key(key)

  check_year(year, min_year = 1989)

  url <- make_url("basic", year, month, vars, key)

  message(paste("Getting basic monthly CPS microdata for", month.name[month], year))

  df <- get_data(url, show_url, tibble, convert)

  df
}


make_url <- function(dataset, year, month, vars, key) {
  check_month(month)
  check_vars(vars)

  month_abb <- tolower(month.abb[month])
  collapsed_vars <- toupper(paste(vars, collapse = ","))

  url <- httr::modify_url(
    url = "https://api.census.gov",
    path = paste("data", year, "cps", dataset, month_abb, sep = "/"),
    query = list(get = collapsed_vars, key = key)
  )

  url
}


get_data <- function(url, show_url, tibble, convert) {
  if (show_url) {
    message("URL: ", sub(pattern = "&key=.*", replacement = "", x = url))
  }

  ua <- httr::user_agent("https://github.com/matt-saenz/cpsR")
  resp <- httr::GET(url, ua)

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

  mat <- jsonlite::fromJSON(httr::content(resp, as = "text"))

  if (!is.matrix(mat) || !is.character(mat)) {
    stop("Census API data not parsed as expected", call. = FALSE)
  }

  df <- build_df(mat, tibble, convert)

  df
}


build_df <- function(mat, tibble, convert) {
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

  df
}
