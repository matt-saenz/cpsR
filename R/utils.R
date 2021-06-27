

get_key <- function() {
  if (Sys.getenv("CENSUS_API_KEY") == "") {
    stop(
      "Census API key not found, supply with `key` argument or env var `CENSUS_API_KEY`",
      call. = FALSE
    )
  }

  Sys.getenv("CENSUS_API_KEY")
}


check_key <- function(key) {
  if (!is.character(key) || length(key) != 1 || key == "") {
    stop("`key` must be a non-empty string", call. = FALSE)
  }
}


format_vars <- function(vars) {
  if (!is.character(vars)) {
    stop("`vars` must be a character vector", call. = FALSE)
  }

  if (any(grepl(pattern = "[^A-Za-z0-9_]", x = vars))) {
    stop(
      "Elements of `vars` must only contain letters, digits, and underscores",
      call. = FALSE
    )
  }

  if (any(duplicated(vars))) {
    stop("`vars` must not contain any duplicate elements", call. = FALSE)
  }

  paste(toupper(vars), collapse = ",")
}


check_year <- function(year, dataset) {

  # Check available years here: https://data.census.gov/mdat/#/

  lookup <- list(
    asec = 2014:2020,
    basic = 1994:2021
  )

  years <- lookup[[dataset]]

  if (!is.numeric(year) || length(year) != 1) {
    stop("`year` must be a number", call. = FALSE)
  }

  if (!(year %in% years)) {
    stop(
      "Invalid `year`, years ", min(years), " to ", max(years), " are currently supported",
      call. = FALSE
    )
  }
}
