

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

  lookup_years <- list(
    basic = 1994:2021,
    asec = 2014:2020
  )

  years <- lookup_years[[dataset]]

  if (length(year) != 1 || !is.numeric(year)) {
    stop("Pass one `year` at a time as a number", call. = FALSE)
  }

  if (!(year %in% years)) {
    stop(
      glue::glue("Years {years[1]} through {years[length(years)]} are supported"),
      call. = FALSE
    )
  }
}


get_data <- function(url, show_url) {
  if (show_url) {
    message("URL: ", sub(pattern = "&key=.*", replacement = "", x = url))
  }

  # Get data from Census API

  resp <- httr::GET(url, httr::progress())
  cat("\n") # https://github.com/r-lib/httr/issues/344

  # Check response

  httr::stop_for_status(resp, task = "download data")

  if (httr::http_type(resp) != "application/json") {
    stop("Census API did not return JSON", call. = FALSE)
  }

  # Clean and return

  mat <- jsonlite::fromJSON(httr::content(resp, as = "text")) # Matrix

  if (!is.matrix(mat)) {
    stop("Census API data not parsed as expected", call. = FALSE)
  }

  col_names <- mat[1, , drop = TRUE] # Character vector of column names
  cols <- mat[-1, , drop = FALSE] # Matrix of columns
  df <- as.data.frame(cols)
  names(df) <- tolower(col_names)
  df
}


convert_cols <- function(df, noisy = FALSE) {

  # For each column, check if strictly numeric and convert when possible

  for (i in seq_along(df)) {

    # Skip if column is already numeric

    if (is.numeric(df[[i]])) {
      next
    }

    # Test: Does coercing to numeric result in any `NA` values? If not,
    # convert to numeric.

    numeric_col <- suppressWarnings(
      !any(is.na(as.numeric(df[[i]])))
    )

    if (numeric_col) {
      if (noisy) {
        col_name <- names(df)[i]
        message("Converting column `", col_name, "` to numeric")
      }
      df[[i]] <- as.numeric(df[[i]])
    }
  }

  df
}
