## Prepare the `tx_housing_markets` dataset
## Sources:
##   - Housing: ggplot2::txhousing, originally from the TAMU Real Estate
##     Center (https://trerc.tamu.edu/)
##   - Inflation: Consumer Price Index for All Urban Consumers: All Items in
##     South (CUUR0300SA0), U.S. Bureau of Labor Statistics, retrieved from
##     FRED (https://fred.stlouisfed.org/series/CUUR0300SA0). Texas is in the
##     BLS South region; no monthly CPI is published for Texas alone


library(tidyverse)

# Read the inflation data. The file was downloaded manually as a CSV from
# https://fred.stlouisfed.org/series/CUUR0300SA0 on 26 October 2026 and saved
# here, so the script gives the same result even if FRED revises the figures
cpi <- read_csv("data-raw/cuur0300sa0.csv", na = c("", "NA", ".")) |>
  # FRED files have two columns: the date and the index value
  rename(date = 1, cpi = 2) |>
  filter(date >= as.Date("2000-01-01"), date <= as.Date("2015-07-01"))

# Express all prices in July 2015 dollars (the last month in the housing data)
base_cpi <- cpi$cpi[cpi$date == as.Date("2015-07-01")]

# Prepare the housing data and add inflation-adjusted prices
tx_housing_markets <- ggplot2::txhousing |>
  # These are MLS market areas, not always cities, so use a clearer name
  rename(area = city) |>
  mutate(
    # Replace the decimal-year date (e.g. 2015.5) with a real date:
    # the first day of each month
    date = make_date(year, month, 1),
    # Label each month with its phase of the housing cycle.
    # Cut-offs follow total sales across all 46 areas
    # Peaked in 2006 and were lowest in 2010 (excluding partial-year 2015)
    period = case_when(
      year <= 2006 ~ "Pre-crisis (2000-2006)",
      year <= 2010 ~ "Downturn (2007-2010)",
      TRUE         ~ "Recovery (2011-2015)"
    ),
    # Store as a factor so the phases stay in time order
    period = factor(
      period,
      levels = c("Pre-crisis (2000-2006)",
                 "Downturn (2007-2010)",
                 "Recovery (2011-2015)")
    )
  ) |>
  # Join each month's CPI value to the housing data
  left_join(cpi, by = "date") |>
  # Convert the median price to July 2015 dollars, removing inflation
  mutate(median_real = round(median * base_cpi / cpi)) |>
  # Put the columns in a sensible order and sort by area, then date
  select(area, date, year, month, period,
         sales, volume, median, median_real, listings, inventory) |>
  arrange(area, date)

usethis::use_data(tx_housing_markets, overwrite = TRUE)
