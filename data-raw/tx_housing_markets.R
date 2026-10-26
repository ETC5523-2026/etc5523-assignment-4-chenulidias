## Prepare the `tx_housing_markets` dataset
## Source: ggplot2::txhousing, originally from the TAMU Real Estate Center
## (https://trerc.tamu.edu/)

library(tidyverse)

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
  # Put the columns in a sensible order and sort by area, then date
  select(area, date, year, month, period,
         sales, volume, median, listings, inventory) |>
  arrange(area, date)

usethis::use_data(tx_housing_markets, overwrite = TRUE)
