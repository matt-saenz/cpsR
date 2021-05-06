

check_key <- function(key) {
  if (is.null(key)) {
    if (Sys.getenv("CENSUS_API_KEY") == "") {
      stop("You must provide a Census API `key`", call. = FALSE)
    }
    Sys.getenv("CENSUS_API_KEY")
  } else {
    message("Store your `key` in env var `CENSUS_API_KEY` to pass automatically")
    key
  }
}


check_vars <- function(vars) {
  if (!is.character(vars)) {
    stop("Pass `vars` as a character vector", call. = FALSE)
  }

  if (any(grepl(pattern = ",", x = vars))) {
    stop(
      "Each element of `vars` character vector must correspond to single variable",
      call. = FALSE
    )
  }

  paste(toupper(vars), collapse = ",") # Format for Census API
}


check_year <- function(year, dataset) {

  # Check available years here: https://data.census.gov/mdat/#/

  lookup <- list(
    basic = 1994:2021,
    asec = 2014:2020
  )

  years <- lookup[[dataset]]

  if (length(year) != 1 || !is.numeric(year)) {
    stop("Pass one `year` at a time as a number", call. = FALSE)
  }

  if (!(year %in% years)) {
    stop(
      "Invalid `year`, years ", min(years), " to ", max(years),
      " are currently supported",
      call. = FALSE
    )
  }
}
