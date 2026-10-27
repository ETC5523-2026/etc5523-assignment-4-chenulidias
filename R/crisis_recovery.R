#' Summarise how housing markets fell and recovered around the 2008 crisis
#'
#' For each market area, finds the highest yearly level before the crisis
#' (2000-2006), the lowest yearly level during the downturn (2007-2010), how
#' far the area fell between the two, and the first later year in which it
#' returned to its pre-crisis peak.
#'
#' Each year's level is the average of the available monthly values in that
#' year. Using averages rather than totals means years with missing months,
#' and the partial year 2015 (January to July), can still be compared with
#' full years. Because 2015 only covers the first seven months, its average
#' may differ slightly from a full-year figure due to seasonal patterns.
#'
#' @param data A data frame with the same columns as [tx_housing_markets].
#'   Defaults to [tx_housing_markets].
#' @param measure The measure to summarise: `"sales"` (number of homes sold),
#'   `"median_real"` (median sale price in July 2015 dollars) or `"median"`
#'   (median sale price, not adjusted for inflation).
#' @param areas Optional character vector of area names to include. Defaults
#'   to all areas in `data`.
#' @return A tibble with one row per area and the columns:
#' \describe{
#'   \item{area}{Market area.}
#'   \item{measure}{The measure summarised.}
#'   \item{peak_year, peak}{Year and level of the pre-crisis peak.}
#'   \item{low_year, low}{Year and level of the downturn low.}
#'   \item{drop_pct}{Percentage change from peak to low. Negative values
#'     mean the area fell.}
#'   \item{recovery_year}{First year after the low in which the level was
#'     back at or above the pre-crisis peak, or `NA` if this did not happen.}
#'   \item{years_to_recover}{Years from the low to recovery, or `NA`.}
#'   \item{status}{"Recovered", "Not recovered by 2015", "Never fell below
#'     peak" or "Insufficient data".}
#' }
#' @importFrom dplyr case_when filter group_by inner_join left_join mutate
#'   select slice_max slice_min summarise tibble ungroup
#' @export
#' @examples
#' crisis_recovery(measure = "sales", areas = c("Austin", "Dallas", "Houston"))
#' # How far home sales fell in three large markets, and whether they recovered
#'
#' crisis_recovery(measure = "median_real") |>
#'   dplyr::slice_min(drop_pct, n = 5)
#' # The five areas with the biggest fall in inflation-adjusted prices
crisis_recovery <- function(data = tx_housing_markets,
                            measure = "sales",
                            areas = NULL) {

  # Check the measure is one of the three allowed options
  if (!measure %in% c("sales", "median_real", "median")) {
    stop('`measure` must be "sales", "median_real" or "median".',
         call. = FALSE)
  }

  # Keep only the requested areas, stopping with a helpful message if any
  # name isn't in the data (for example, a typo)
  if (!is.null(areas)) {
    unknown <- setdiff(areas, unique(data$area))
    if (length(unknown) > 0) {
      stop("Unknown area(s): ", paste(unknown, collapse = ", "),
           call. = FALSE)
    }
    data <- filter(data, area %in% areas)
  }

  # Copy the chosen measure into a column called `value`, so the steps
  # below work the same way whichever measure was chosen
  data$value <- data[[measure]]

  # 1. Yearly levels: average each area's monthly values within each year,
  #    ignoring missing months. Years with no data at all give NaN, so
  #    those are removed
  yearly <- data |>
    group_by(area, year) |>
    summarise(value = mean(value, na.rm = TRUE), .groups = "drop") |>
    filter(is.finite(value))

  # 2. Pre-crisis peak: each area's highest yearly level from 2000 to 2006
  peaks <- yearly |>
    filter(year <= 2006) |>
    group_by(area) |>
    slice_max(value, n = 1, with_ties = FALSE) |>
    ungroup() |>
    select(area, peak_year = year, peak = value)

  # 3. Downturn low: each area's lowest yearly level from 2007 to 2010
  lows <- yearly |>
    filter(year >= 2007, year <= 2010) |>
    group_by(area) |>
    slice_min(value, n = 1, with_ties = FALSE) |>
    ungroup() |>
    select(area, low_year = year, low = value)

  # 4. Recovery: the first year after the low in which the level was back
  #    at or above the pre-crisis peak (only for areas that actually fell)
  recoveries <- yearly |>
    inner_join(peaks, by = "area") |>
    inner_join(lows, by = "area") |>
    filter(low < peak, year > low_year, value >= peak) |>
    group_by(area) |>
    summarise(recovery_year = min(year), .groups = "drop")

  # 5. Combine into one row per area and label each area's outcome.
  #    Starting from every area means areas missing pre-crisis or downturn
  #    data still appear, labelled "Insufficient data"
  tibble(area = sort(unique(data$area))) |>
    left_join(peaks, by = "area") |>
    left_join(lows, by = "area") |>
    left_join(recoveries, by = "area") |>
    mutate(
      measure = measure,
      drop_pct = round((low - peak) / peak * 100, 1),
      years_to_recover = recovery_year - low_year,
      status = case_when(
        is.na(peak) | is.na(low) ~ "Insufficient data",
        low >= peak              ~ "Never fell below peak",
        !is.na(recovery_year)    ~ "Recovered",
        TRUE                     ~ "Not recovered by 2015"
      ),
      peak = round(peak, 1),
      low = round(low, 1)
    ) |>
    select(area, measure, peak_year, peak, low_year, low,
           drop_pct, recovery_year, years_to_recover, status)
}
