is_number <- function(x) is.numeric(x) && length(x) == 1
is_string <- function(x) is.character(x) && length(x) == 1
`%!in%` <- function(x, table) match(x, table, nomatch = 0) == 0


get_key <- function() {
  key <- Sys.getenv("CENSUS_API_KEY")

  if (key == "") {
    stop(
      "Census API key not found, supply with `key` argument or env var `CENSUS_API_KEY`",
      call. = FALSE
    )
  }

  key
}


check_key <- function(key) {
  if (!is_string(key) || key == "") {
    stop("`key` must be a non-empty string", call. = FALSE)
  }
}


check_vars <- function(vars) {
  if (!is.character(vars)) {
    stop("`vars` must be a character vector", call. = FALSE)
  }

  if (any(grepl(pattern = "[^A-Za-z0-9_]", x = vars))) {
    stop(
      "Elements of `vars` must only contain letters, digits, and underscores",
      call. = FALSE
    )
  }

  if (any(duplicated(tolower(vars)))) {
    stop("`vars` must not contain any duplicate elements", call. = FALSE)
  }
}


check_year <- function(year, min_year) {
  if (!is_number(year)) {
    stop("`year` must be a number", call. = FALSE)
  }

  if (year < min_year) {
    stop(
      "Invalid `year`, years ", min_year, " and on are currently supported",
      call. = FALSE
    )
  }
}


check_month <- function(month) {
  if (!is_number(month) || month %!in% 1:12) {
    stop("`month` must be a number ranging from 1 to 12", call. = FALSE)
  }
}
