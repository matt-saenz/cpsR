
<!-- README.md is generated from README.Rmd. Please edit that file -->

# cpsR

<!-- badges: start -->

[![CRAN
status](https://www.r-pkg.org/badges/version/cpsR)](https://CRAN.R-project.org/package=cpsR)
[![Project Status: Active – The project has reached a stable, usable
state and is being actively
developed.](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active)
[![CRAN
downloads](https://cranlogs.r-pkg.org/badges/grand-total/cpsR)](https://cran.r-project.org/package=cpsR)
[![R-CMD-check](https://github.com/matt-saenz/cpsR/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/matt-saenz/cpsR/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

## Overview

Load [Current Population Survey
(CPS)](https://www.census.gov/programs-surveys/cps/about.html) microdata
into R using the Census Bureau Data API, including [basic monthly
CPS](https://www.census.gov/data/datasets/time-series/demo/cps/cps-basic.html)
and [CPS
ASEC](https://www.census.gov/data/datasets/time-series/demo/cps/cps-asec.html)
microdata.

Note: This product uses the Census Bureau Data API but is not endorsed
or certified by the Census Bureau.

## Installation

To install cpsR, run the following code:

``` r
install.packages("cpsR")
```

To install the development version of cpsR, run the following code:

``` r
# install.packages("devtools")
devtools::install_github("matt-saenz/cpsR")
```

## Census API key

In order to use cpsR functions, you must supply a [Census API
key](https://api.census.gov/data/key_signup.html) in one of two ways:

1.  Using the `key` argument (manually)
2.  Using environment variable `CENSUS_API_KEY` (automatically)

Using environment variable (or env var, for short) `CENSUS_API_KEY` is
strongly recommended for two reasons:

1.  Saves you from having to copy-paste your key around
2.  Allows you to avoid including your key in scripts

It is important to avoid including your key in scripts if you plan to
share your code with others (like in the [example](#example) below)
since you should keep your key secret.

You can set up env var `CENSUS_API_KEY` in two steps:

First, open your `.Renviron` file. You can do so by running:

``` r
# install.packages("usethis")
usethis::edit_r_environ()
```

Second, add your Census API key to your `.Renviron` file like so:

    CENSUS_API_KEY="your_key_here"

This enables cpsR functions to automatically look up your key by
running:

``` r
Sys.getenv("CENSUS_API_KEY")
```

## Example

``` r
library(cpsR)
library(dplyr)
library(purrr)


# Simple use of the basic monthly CPS

sep21 <- get_basic(
  year = 2021,
  month = 9,
  vars = c("prpertyp", "prtage", "pemlr", "pwcmpwgt")
)

sep21
#> # A tibble: 103,858 × 4
#>    prpertyp prtage pemlr pwcmpwgt
#>       <int>  <int> <int>    <dbl>
#>  1        2     80     5    1361.
#>  2        2     85     5    1411.
#>  3        2     80     5    4619.
#>  4        2     80     5    4587.
#>  5        2     42     1    3677.
#>  6        2     42     1    3645.
#>  7        1      9    -1       0 
#>  8        2     41     1    3652.
#>  9        2     32     7    4117.
#> 10        2     67     1    2479.
#> # … with 103,848 more rows

sep21 %>%
  filter(prpertyp == 2 & prtage >= 16) %>%
  summarize(
    pop16plus = sum(pwcmpwgt),
    employed = sum(pwcmpwgt[pemlr %in% 1:2])
  ) %>%
  mutate(epop_ratio = employed / pop16plus)
#> # A tibble: 1 × 3
#>    pop16plus   employed epop_ratio
#>        <dbl>      <dbl>      <dbl>
#> 1 261765646. 154025931.      0.588


# Pulling multiple years of CPS ASEC microdata

asec <- map_dfr(2020:2021, get_asec, vars = c("h_year", "marsupwt"))

count(asec, h_year, wt = marsupwt)
#> # A tibble: 2 × 2
#>   h_year          n
#>    <int>      <dbl>
#> 1   2020 325268182.
#> 2   2021 326195440.
```
