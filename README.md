
<!-- README.md is generated from README.Rmd. Please edit that file -->

# cpsR

<!-- badges: start -->

[![R-CMD-check](https://github.com/matt-saenz/cpsR/workflows/R-CMD-check/badge.svg)](https://github.com/matt-saenz/cpsR/actions)
[![Project Status: Active – The project has reached a stable, usable
state and is being actively
developed.](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active)

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
# install.packages("devtools")
devtools::install_github("matt-saenz/cpsR")
```

Next, register for a [Census API
key](https://api.census.gov/data/key_signup.html) if you don’t already
have one. Once you have your key, store it in an environment variable
named `CENSUS_API_KEY` for safe and easy use. You can do this in two
steps:

1.  Run `usethis::edit_r_environ()` to open your `.Renviron` file
2.  Add `CENSUS_API_KEY="your_key_here"` to your `.Renviron` file

This allows cpsR functions to automatically add your key to Census API
requests (via `Sys.getenv("CENSUS_API_KEY")`). Compared to manually
supplying your key with the `key` argument, using env var
`CENSUS_API_KEY` has two main benefits:

1.  Saves you from having to copy-paste your key around
2.  Allows you to avoid including your key in scripts

Number two is particularly important if you plan to share your scripts
with others or post your scripts online (e.g., on GitHub).

## Example

``` r
library(cpsR)
library(dplyr)

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
```
