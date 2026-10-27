# Summarise how housing markets fell and recovered around the 2008 crisis

For each market area, finds the highest yearly level before the crisis
(2000-2006), the lowest yearly level during the downturn (2007-2010),
how far the area fell between the two, and the first later year in which
it returned to its pre-crisis peak.

## Usage

``` r
crisis_recovery(data = tx_housing_markets, measure = "sales", areas = NULL)
```

## Arguments

- data:

  A data frame with the same columns as
  [tx_housing_markets](https://etc5523-2026.github.io/etc5523-assignment-4-chenulidias/reference/tx_housing_markets.md).
  Defaults to
  [tx_housing_markets](https://etc5523-2026.github.io/etc5523-assignment-4-chenulidias/reference/tx_housing_markets.md).

- measure:

  The measure to summarise: `"sales"` (number of homes sold),
  `"median_real"` (median sale price in July 2015 dollars) or `"median"`
  (median sale price, not adjusted for inflation).

- areas:

  Optional character vector of area names to include. Defaults to all
  areas in `data`.

## Value

A tibble with one row per area and the columns:

- area:

  Market area.

- measure:

  The measure summarised.

- peak_year, peak:

  Year and level of the pre-crisis peak.

- low_year, low:

  Year and level of the downturn low.

- drop_pct:

  Percentage change from peak to low. Negative values mean the area
  fell.

- recovery_year:

  First year after the low in which the level was back at or above the
  pre-crisis peak, or `NA` if this did not happen.

- years_to_recover:

  Years from the low to recovery, or `NA`.

- status:

  "Recovered", "Not recovered by 2015", "Never fell below peak" or
  "Insufficient data".

## Details

Each year's level is the average of the available monthly values in that
year. Using averages rather than totals means years with missing months,
and the partial year 2015 (January to July), can still be compared with
full years. Because 2015 only covers the first seven months, its average
may differ slightly from a full-year figure due to seasonal patterns.

## Examples

``` r
crisis_recovery(measure = "sales", areas = c("Austin", "Dallas", "Houston"))
#> # A tibble: 3 × 10
#>   area    measure peak_year  peak low_year   low drop_pct recovery_year
#>   <chr>   <chr>       <int> <dbl>    <int> <dbl>    <dbl>         <int>
#> 1 Austin  sales        2006 2524.     2010 1656     -34.4          2013
#> 2 Dallas  sales        2006 5352.     2010 3532.    -34              NA
#> 3 Houston sales        2006 6750.     2010 4734.    -29.9          2014
#> # ℹ 2 more variables: years_to_recover <int>, status <chr>
# How far home sales fell in three large markets, and whether they recovered

crisis_recovery(measure = "median_real") |>
  dplyr::slice_min(drop_pct, n = 5)
#> # A tibble: 5 × 10
#>   area        measure    peak_year   peak low_year    low drop_pct recovery_year
#>   <chr>       <chr>          <int>  <dbl>    <int>  <dbl>    <dbl>         <int>
#> 1 Galveston   median_re…      2006 2.05e5     2009 1.39e5    -32.3            NA
#> 2 Garland     median_re…      2002 1.45e5     2010 1.05e5    -27.8            NA
#> 3 Brownsville median_re…      2005 1.29e5     2009 1.02e5    -20.6            NA
#> 4 Laredo      median_re…      2004 1.59e5     2010 1.28e5    -19.8            NA
#> 5 Harlingen   median_re…      2000 1.14e5     2010 9.18e4    -19.7            NA
#> # ℹ 2 more variables: years_to_recover <int>, status <chr>
# The five areas with the biggest fall in inflation-adjusted prices
```
