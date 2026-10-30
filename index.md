# txhome

**txhome** helps you explore how Texas housing markets weathered the
2008 financial crisis. It contains monthly housing data for 46 Texas
market areas from 2000 to 2015, a function that measures how far each
market fell during the crisis and how quickly it recovered, and an
interactive Shiny app for comparing markets.

Website:
<https://etc5523-2026.github.io/etc5523-assignment-4-chenulidias/>

## Who it’s for and the question it answers

The package is designed for **economics students studying how the 2008
financial crisis affected regional housing markets**. It helps answer:

> Which Texas housing markets were hit hardest by the 2007-2010
> downturn, and how quickly did they recover?

The 2007-2009 financial crisis was the worst US downturn since the Great
Depression, and it is widely studied in economics because it began in
the housing market. Texas is a well-known case: it escaped the worst of
the crash, but its local markets were not affected equally (Kumar and
Skelton, [Federal Reserve Bank of Dallas,
2013](https://www.dallasfed.org/~/media/documents/research/swe/2013/swe1303a.pdf)).

The package lets students compare how far different Texas markets fell
and how quickly they recovered, and see why economists adjust prices for
inflation: in this data, many markets only appear unaffected until
inflation is removed. The data is ready to use, the app needs no coding
and explains each measure in plain language, and
[`crisis_recovery()`](https://etc5523-2026.github.io/etc5523-assignment-4-chenulidias/reference/crisis_recovery.md)
gives the figures for any market in one line.

## Installation

Install the package from GitHub:

``` r

# install.packages("remotes")
remotes::install_github("ETC5523-2026/etc5523-assignment-4-chenulidias")
```

The package requires R 4.1 or later. Its dependencies (dplyr, shiny,
bslib, ggplot2 and scales) are installed automatically.

## Launch the app

``` r

library(txhome)
run_app()
```

In the app, choose one or more market areas and a measure (homes sold,
or the median sale price with or without an adjustment for inflation).
Two headline boxes show which chosen area was hit hardest and which
recovered fastest, and three tabs show the areas over time, a summary
table, and a ranking of every area in Texas.

## Use the summary function

[`crisis_recovery()`](https://etc5523-2026.github.io/etc5523-assignment-4-chenulidias/reference/crisis_recovery.md)
summarises each area’s pre-crisis peak, downturn low, percentage fall
and recovery year:

``` r

crisis_recovery(measure = "sales", areas = c("Austin", "Dallas", "Houston"))
```

For example, home sales in Austin, Dallas and Houston each fell by
roughly 30-35% from 2006 to 2010. Austin was back at its pre-crisis
level by 2013, while Dallas had still not recovered by mid-2015.

## Data

The package includes one dataset, `tx_housing_markets`: monthly sales,
prices, listings and inventory for 46 Texas market areas from January
2000 to July 2015.

- **Housing data:** collected by the Texas A&M University (TAMU) Real
  Estate Center (<https://trerc.tamu.edu/>), using the copy distributed
  in the ggplot2 package as
  [`ggplot2::txhousing`](https://ggplot2.tidyverse.org/reference/txhousing.html).
- **Inflation data:** the Consumer Price Index for the US South region
  (CUUR0300SA0) from the US Bureau of Labor Statistics, retrieved from
  FRED (<https://fred.stlouisfed.org/series/CUUR0300SA0>). It is used to
  convert median prices into July 2015 dollars, so prices from different
  years can be compared fairly.

The script `data-raw/tx_housing_markets.R` prepares the data: it renames
`city` to `area` (since many are counties or regions), converts decimal
years into proper monthly dates, labels each month as pre-crisis
(2000-2006), downturn (2007-2010) or recovery (2011-2015), and joins the
inflation data to calculate inflation-adjusted median prices. To
recreate the dataset, run `source("data-raw/tx_housing_markets.R")` from
the package’s source folder. See
[`?tx_housing_markets`](https://etc5523-2026.github.io/etc5523-assignment-4-chenulidias/reference/tx_housing_markets.md)
for a description of every column.

**Limitations:** the data end in July 2015, so later recoveries are not
captured; market areas are MLS (multiple listing service) regions rather
than exact city boundaries; and two areas (Kerrville and South Padre
Island) have no data before 2007, so their fall and recovery cannot be
measured.

## Generative AI declaration

Generative AI declaration: I used Claude (Anthropic) to help plan the
package’s structure; explain, write and debug R code and concepts for
the data preparation script, the
[`crisis_recovery()`](https://etc5523-2026.github.io/etc5523-assignment-4-chenulidias/reference/crisis_recovery.md)
function and the Shiny app; design the app’s figures, layout and
styling; refine and draft the wording of the README, vignette,
documentation and app text; and troubleshoot the pkgdown setup. I
checked, tested and revised all generated code and text, and I
understand and take responsibility for the final work.

## License

MIT. See
[LICENSE.md](https://etc5523-2026.github.io/etc5523-assignment-4-chenulidias/LICENSE.md)
for the full licence text.
