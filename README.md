
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
from the Census Bureau Data API into R, including [basic monthly
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

Next, store your [Census API
key](https://api.census.gov/data/key_signup.html) in an environment
variable named `CENSUS_API_KEY` for safe and easy use. You can do this
by:

1.  Running `usethis::edit_r_environ()` to open your `.Renviron` file
2.  Adding `CENSUS_API_KEY="your_key_here"` to your `.Renviron` file

## Example

``` r
library(cpsR)
library(dplyr)

basic <- get_basic(
  year = 2021,
  month = 3,
  vars = c("prpertyp", "prtage", "pemlr", "pwcmpwgt")
)

basic
#> # A tibble: 107,334 × 4
#>    prpertyp prtage pemlr pwcmpwgt
#>       <dbl>  <dbl> <dbl>    <dbl>
#>  1        2     55     5    3768.
#>  2        2     59     5    3474.
#>  3        2     26     1    4511.
#>  4        2     68     5    1852.
#>  5        2     69     5    1960.
#>  6        2     41     7    4024.
#>  7        2     41     1    3677.
#>  8        1     12    -1       0 
#>  9        1      8    -1       0 
#> 10        2     70     5    1353.
#> # … with 107,324 more rows
basic %>%
  filter(prpertyp == 2 & prtage >= 16) %>%
  summarize(
    pop16plus = sum(pwcmpwgt),
    employed = sum(pwcmpwgt[pemlr %in% 1:2])
  ) %>%
  mutate(epop_ratio = employed / pop16plus)
#> # A tibble: 1 × 3
#>    pop16plus   employed epop_ratio
#>        <dbl>      <dbl>      <dbl>
#> 1 261003019. 150492839.      0.577
```
