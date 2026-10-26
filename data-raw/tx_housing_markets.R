## Prepare the `tx_housing_markets` dataset
## Source: ggplot2::txhousing, originally from the TAMU Real Estate Center
## (https://trerc.tamu.edu/)

library(dplyr)

tx_housing_markets <- ggplot2::txhousing |>
  # These are MLS market areas, not always cities, so use a clearer name
  rename(area = city) |>
  mutate(
    # The original `date` is a decimal year (e.g. 2015.5); build a real date
    # for the first day of each month instead
    date = as.Date(sprintf("%d-%02d-01", year, month)),
    # Label each month with its phase of the housing cycle. The cut-offs
    # follow statewide sales, which peaked in 2006 and bottomed out in 2010
    period = case_when(
      year <= 2006 ~ "Pre-crisis (2000-2006)",
      year <= 2010 ~ "Downturn (2007-2010)",
      TRUE         ~ "Recovery (2011-2015)"
    ),
    period = factor(
      period,
      levels = c("Pre-crisis (2000-2006)",
                 "Downturn (2007-2010)",
                 "Recovery (2011-2015)")
    )
  ) |>
  select(area, date, year, month, period,
         sales, volume, median, listings, inventory) |>
  arrange(area, date)

usethis::use_data(tx_housing_markets, overwrite = TRUE)
