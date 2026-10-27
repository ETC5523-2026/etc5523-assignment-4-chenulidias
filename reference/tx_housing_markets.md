# Monthly housing market data for Texas MLS areas, 2000-2015

A cleaned version of
[`ggplot2::txhousing`](https://ggplot2.tidyverse.org/reference/txhousing.html),
with one row per market area per month, plus inflation-adjusted median
prices. Used to explore how Texas housing markets changed before, during
and after the 2008 financial crisis.

## Usage

``` r
tx_housing_markets
```

## Format

A tibble with 8,602 rows and 11 columns:

- area:

  Multiple listing service (MLS) area. Most are cities, but some are
  counties or regions, such as Collin County or Bay Area.

- date:

  The month the figures refer to, stored as the first day of that month.

- year:

  Year.

- month:

  Month, from 1 (January) to 12 (December).

- period:

  Phase of the housing cycle: Pre-crisis (2000-2006), Downturn
  (2007-2010) or Recovery (2011-2015). The cut-offs follow total sales
  across all 46 areas, which peaked in 2006 and were lowest in 2010.

- sales:

  Number of homes sold.

- volume:

  Total value of sales, in US dollars.

- median:

  Median sale price, in US dollars, as reported at the time (not
  adjusted for inflation).

- median_real:

  Median sale price adjusted for inflation, in July 2015 US dollars,
  using the Consumer Price Index for the US South region.

- listings:

  Total active listings.

- inventory:

  Months inventory: the time it would take to sell all current listings
  at the current pace of sales.

## Source

Housing data: originally collected by the Texas A&M University (TAMU)
Real Estate Center, <https://trerc.tamu.edu/>. This package uses the
copy distributed in the ggplot2 package as
[`ggplot2::txhousing`](https://ggplot2.tidyverse.org/reference/txhousing.html).

Inflation data: U.S. Bureau of Labor Statistics, Consumer Price Index
for All Urban Consumers: All Items in South (CUUR0300SA0), retrieved
from FRED, Federal Reserve Bank of St. Louis,
<https://fred.stlouisfed.org/series/CUUR0300SA0>.

## Details

The data run from January 2000 to July 2015, so 2015 is a partial year.
`median_real` converts each month's median price to July 2015 dollars,
so prices from different years can be compared fairly. It uses the CPI
for the US South region, which includes Texas, because no monthly CPI is
published for Texas alone. Some areas have missing values, particularly
for listings and inventory; these are kept as `NA` rather than removed.
The script used to prepare the data is `data-raw/tx_housing_markets.R`
in the package source.
