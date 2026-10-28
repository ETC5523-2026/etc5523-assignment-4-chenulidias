# Compare how Texas housing markets weathered the 2008 crisis

This guide shows how to use txhome to answer one question:

> Which Texas housing markets were hit hardest by the 2007-2010
> downturn, and how quickly did they recover?

It is written for economics students studying how the 2008 financial
crisis affected regional housing markets, and assumes no previous
experience with the package. It covers how to install the package,
launch and use the app, and interpret the results.

## Install the package

``` r

# install.packages("remotes")
remotes::install_github("ETC5523-2026/etc5523-assignment-4-chenulidias")
```

## Launch the app

``` r

library(txhome)
run_app()
```

## Use the app

The sidebar has three controls:

1.  **Choose market areas:** pick one or more of Texas’s 46 market
    areas. A market area is a local housing market, usually a city or
    county.
2.  **Choose a measure:** homes sold (the average number sold each
    month), the median sale price adjusted for inflation (in July 2015
    dollars), or the median sale price as reported at the time.
3.  **Compare areas as a percentage of their pre-crisis peak:** rescales
    every area so its highest yearly level from 2000 to 2006 equals 100.
    This lets you compare large and small markets on the same chart.

The app then shows:

- **Two headline boxes:** the chosen area that was hit hardest and the
  one that recovered fastest.
- **Over time:** each chosen area from 2000 to 2015, with the 2007-2010
  downturn shaded.
- **Summary table:** each area’s pre-crisis peak, downturn low,
  percentage fall, and the year it got back to its peak. The table can
  be downloaded as a CSV file for use in your own work.
- **All areas ranked:** how far every Texas market fell, with your
  chosen areas highlighted.

If no areas are chosen, the app asks you to choose one. Kerrville and
South Padre Island have no data before 2007, so the app explains that
their fall and recovery can’t be measured.

## Interpret the outputs

The app’s figures come from the package’s
[`crisis_recovery()`](https://etc5523-2026.github.io/etc5523-assignment-4-chenulidias/reference/crisis_recovery.md)
function, which you can also use directly. For each area, it finds:

- the **pre-crisis peak:** the highest yearly level from 2000 to 2006;
- the **downturn low:** the lowest yearly level from 2007 to 2010;
- the **change** from peak to low, as a percentage; and
- the **recovery year:** the first later year the area got back to its
  peak.

Each yearly level is the average of that year’s monthly values.

``` r

library(txhome)
crisis_recovery(measure = "sales", areas = c("Austin", "Dallas", "Houston")) |>
  dplyr::select(area, peak_year, peak, low_year, low, drop_pct,
                recovery_year, status) |>
  knitr::kable(
    col.names = c("Area", "Peak year", "Pre-crisis peak", "Low year",
                  "Downturn low", "Change (%)", "Back at peak in", "Status"),
    digits = 1
  )
```

| Area | Peak year | Pre-crisis peak | Low year | Downturn low | Change (%) | Back at peak in | Status |
|:---|---:|---:|---:|---:|---:|---:|:---|
| Austin | 2006 | 2523.7 | 2010 | 1656.0 | -34.4 | 2013 | Recovered |
| Dallas | 2006 | 5352.2 | 2010 | 3531.9 | -34.0 | \- | Not recovered by 2015 |
| Houston | 2006 | 6749.5 | 2010 | 4733.9 | -29.9 | 2014 | Recovered |

Sales figures are average homes sold per month. Home sales in all three
markets peaked in 2006 and were lowest in 2010, falling by roughly
30-35%. Their recoveries differed: Austin was back at its pre-crisis
level by 2013, Houston by 2014, while Dallas had still not recovered
when the data end in mid-2015.

## A key finding: inflation hides real price falls

The app lets you switch between prices as reported and prices adjusted
for inflation. This changes the answer to “did prices fall during the
crisis?”. The table counts how many of the 46 areas fall into each
outcome under each measure:

``` r

nominal <- crisis_recovery(measure = "median") |>
  dplyr::count(status, name = "Prices as reported")
real <- crisis_recovery(measure = "median_real") |>
  dplyr::count(status, name = "Adjusted for inflation")

dplyr::full_join(nominal, real, by = "status") |>
  dplyr::mutate(
    `Prices as reported` = dplyr::coalesce(`Prices as reported`, 0L),
    `Adjusted for inflation` = dplyr::coalesce(`Adjusted for inflation`, 0L)
  ) |>
  dplyr::rename(Outcome = status) |>
  knitr::kable()
```

| Outcome               | Prices as reported | Adjusted for inflation |
|:----------------------|-------------------:|-----------------------:|
| Insufficient data     |                  2 |                      2 |
| Never fell below peak |                 32 |                     11 |
| Recovered             |                 12 |                     25 |
| Not recovered by 2015 |                  0 |                      8 |

Using prices as reported, most areas never fell below their pre-crisis
peak. After adjusting for inflation, most areas did fall, and several
had not recovered by 2015. Because prices in general rise over time, a
home’s price can look steady while its real value is falling.

## Limitations

- The data end in July 2015, so recoveries after that are not captured.
- Market areas are MLS (multiple listing service) regions, not exact
  city boundaries.
- Median prices depend on which homes sell, so they can change even if
  individual home values do not.
- The inflation adjustment uses the CPI for the US South region, which
  includes Texas but is not specific to it.

## Data sources

Housing data were collected by the [TAMU Real Estate
Center](https://trerc.tamu.edu/) and are distributed in the ggplot2
package as
[`ggplot2::txhousing`](https://ggplot2.tidyverse.org/reference/txhousing.html).
Inflation data are the [US Bureau of Labor Statistics South region
CPI](https://fred.stlouisfed.org/series/CUUR0300SA0), retrieved from
FRED.
