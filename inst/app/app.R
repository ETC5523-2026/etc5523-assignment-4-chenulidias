library(shiny)
library(bslib)
library(dplyr)
library(ggplot2)
library(txhome)

# The measures users can choose
measure_choices <- c(
  "Homes sold" = "sales",
  "Median price, adjusted for inflation" = "median_real",
  "Median price, as reported" = "median"
)

# Clear axis labels for each measure
measure_axis <- c(
  sales = "Average homes sold per month",
  median_real = "Median sale price (July 2015 dollars)",
  median = "Median sale price (dollars at the time)"
)

# Short names used in titles
measure_short <- c(
  sales = "home sales",
  median_real = "inflation-adjusted median prices",
  median = "median prices (not adjusted for inflation)"
)

# Units shown once in the table's column headings
measure_unit <- c(
  sales = "(homes per month)",
  median_real = "(July 2015 $)",
  median = "($ at the time)"
)

# Format axis numbers: commas for sales, dollar signs for prices
axis_labels <- function(measure) {
  if (measure == "sales") scales::label_comma() else scales::label_dollar()
}

# Source note shown under each output
source_note <- p(
  class = "text-muted small",
  "Source: TAMU Real Estate Center (via the ggplot2 package). Inflation",
  "adjustment uses the US Bureau of Labor Statistics South region CPI."
)

ui <- page_sidebar(
  title = "Texas housing markets and the 2008 crisis",
  theme = bs_theme(bootswatch = "flatly"),
  fillable = FALSE,
  sidebar = sidebar(
    width = 320,
    selectInput(
      "areas", "1. Choose market areas",
      choices = sort(unique(tx_housing_markets$area)),
      selected = c("Austin", "Dallas", "Houston"),
      multiple = TRUE
    ),
    helpText("Pick one or more of Texas's 46 market areas to compare.",
             "Type a name to search."),
    radioButtons(
      "measure", "2. Choose a measure",
      choices = measure_choices,
      selected = "sales"
    ),
    helpText(
      strong("Homes sold:"), "the average number of homes sold each month.",
      "It shows how busy the market was.", br(),
      strong("Median price, adjusted for inflation:"), "the typical sale",
      "price, converted to July 2015 dollars so prices from different",
      "years can be compared fairly.", br(),
      strong("Median price, as reported:"), "the typical sale price in the",
      "dollars of that year."
    ),
    checkboxInput(
      "relative",
      "3. Compare areas as a percentage of their pre-crisis peak",
      value = FALSE
    ),
    helpText("Big markets can make small ones look flat on the chart. Tick",
             "this to show every area on the same scale. Each area's",
             "pre-crisis peak (its highest yearly level from 2000 to 2006)",
             "becomes 100. For example, 70 means 30% below its peak, and",
             "110 means 10% above it."),
    helpText(
      "Data: housing sales from the ",
      a("TAMU Real Estate Center", href = "https://trerc.tamu.edu/"),
      " (via the ggplot2 package); inflation from the ",
      a("US Bureau of Labor Statistics",
        href = "https://fred.stlouisfed.org/series/CUUR0300SA0"),
      ". Covers January 2000 to July 2015."
    )
  ),

  # Who the app is for, the question, and how to use it
  card(
    card_header("About this app"),
    p(strong("For: "), "economics students studying how the 2008 financial",
      "crisis affected regional housing markets."),
    p(strong("Question: "), "Which Texas housing markets were hit hardest by",
      "the 2007-2010 downturn, and how quickly did they recover?"),
    p("A market area is a local housing market, usually a city or county.",
      "Choose areas and a measure on the left. The two boxes below answer",
      "the question for your chosen areas, and the tabs show the details.")
  ),

  # Headline answers to the two parts of the question
  layout_columns(
    fill = FALSE,
    value_box(
      title = "Hardest hit",
      value = textOutput("hardest_name"),
      textOutput("hardest_detail"),
      theme = "text-danger"
    ),
    value_box(
      title = "Fastest recovery",
      value = textOutput("fastest_name"),
      textOutput("fastest_detail"),
      theme = "text-success"
    )
  ),

  # Three views of the same selection
  navset_card_tab(
    nav_panel(
      "Over time",
      plotOutput("trend_plot", height = "480px"),
      source_note,
      p(class = "text-muted",
        strong("How to read: "), "each line shows one area from 2000 to",
        "2015. The grey band marks the 2007-2010 downturn. If a line drops",
        "in the band and later climbs back to where it was before, that",
        "market recovered. With option 3 ticked, the dashed line at 100 is",
        "each area's pre-crisis peak: below it means lower than before the",
        "crisis, above it means higher."),
      # Only shown for prices, where inflation matters
      conditionalPanel(
        condition = "input.measure != 'sales'",
        div(class = "alert alert-info", textOutput("inflation_note"))
      )
    ),
    nav_panel(
      "Summary table",
      h5(textOutput("table_title")),
      tableOutput("recovery_table"),
      source_note,
      p(class = "text-muted", strong("How to read this table:")),
      tags$ul(
        class = "text-muted",
        tags$li(strong("Pre-crisis peak:"), "the area's highest yearly level",
                "from 2000 to 2006, before the crisis."),
        tags$li(strong("Downturn low:"), "its lowest yearly level from 2007",
                "to 2010, during the crisis."),
        tags$li(strong("Change (%):"), "how far it fell from peak to low.",
                "A negative number means it fell."),
        tags$li(strong("Back at peak in:"), "the first year it got back to",
                "its pre-crisis peak. A dash means it hadn't by July 2015,",
                "or it never fell."),
        tags$li(strong("Insufficient data:"), "the area has no records",
                "before 2007, so there's no pre-crisis peak to compare with."),
        tags$li("Each yearly level is the average of that year's months.")
      )
    ),
    nav_panel(
      "All areas ranked",
      p(class = "text-muted",
        strong("How to read: "), "each bar shows how far one area fell from",
        "its pre-crisis peak to its downturn low. Longer bars mean a bigger",
        "fall, with the hardest hit at the top. Your chosen areas are in",
        "orange, so you can see how they compare with the rest of Texas."),
      plotOutput("ranking_plot", height = "1100px"),
      source_note
    )
  )
)

server <- function(input, output, session) {

  # Shared reactive 1: the monthly data for the chosen areas
  selected_data <- reactive({
    validate(
      need(length(input$areas) > 0,
           "Choose at least one market area on the left to see results.")
    )
    tx_housing_markets |>
      filter(area %in% input$areas)
  }, label = "selected_data")

  # Shared reactive 2: the crisis summary for the chosen areas, from the
  # package's crisis_recovery() function. The boxes and table both use it
  selected_recovery <- reactive({
    crisis_recovery(selected_data(), measure = input$measure)
  }, label = "selected_recovery")

  # The crisis summary for every area, used by the ranking chart
  all_recovery <- reactive({
    crisis_recovery(measure = input$measure)
  }, label = "all_recovery")

  # Headline 1: the chosen area with the biggest fall
  hardest <- reactive({
    selected_recovery() |>
      filter(drop_pct < 0) |>
      slice_min(drop_pct, n = 1, with_ties = FALSE)
  }, label = "hardest")

  output$hardest_name <- renderText({
    if (nrow(hardest()) == 0) return("None")
    hardest()$area
  })

  output$hardest_detail <- renderText({
    if (nrow(hardest()) == 0) {
      return(paste("None of these areas fell below their pre-crisis peak",
                   "on this measure, or they have no data before 2007."))
    }
    paste0("Fell ", abs(hardest()$drop_pct), "% from its pre-crisis peak")
  })

  # Headline 2: the chosen area that recovered fastest
  fastest <- reactive({
    selected_recovery() |>
      filter(status == "Recovered") |>
      slice_min(years_to_recover, n = 1, with_ties = FALSE)
  }, label = "fastest")

  output$fastest_name <- renderText({
    if (nrow(fastest()) == 0) return("None yet")
    fastest()$area
  })

  output$fastest_detail <- renderText({
    if (nrow(fastest()) == 0) {
      return("None of these areas was back at its peak by July 2015.")
    }
    years <- fastest()$years_to_recover
    unit <- if (years == 1) "year" else "years"
    paste0("Back at its peak by ", fastest()$recovery_year, ", ",
           years, " ", unit, " after its low")
  })

  # Over-time chart: each chosen area's yearly level, downturn shaded.
  # Optionally rescaled so each area's pre-crisis peak equals 100
  output$trend_plot <- renderPlot({
    yearly <- selected_data()
    yearly$value <- yearly[[input$measure]]
    yearly <- yearly |>
      group_by(area, year) |>
      summarise(value = mean(value, na.rm = TRUE), .groups = "drop") |>
      filter(is.finite(value))

    y_label <- measure_axis[[input$measure]]
    y_scale <- scale_y_continuous(labels = axis_labels(input$measure))

    if (input$relative) {
      # Divide each area's values by its pre-crisis peak
      peaks <- yearly |>
        filter(year <= 2006) |>
        group_by(area) |>
        summarise(peak = max(value), .groups = "drop")
      yearly <- yearly |>
        inner_join(peaks, by = "area") |>
        mutate(value = value / peak * 100)
      validate(
        need(nrow(yearly) > 0,
             paste("These areas have no data before 2007, so they can't",
                   "be compared with a pre-crisis peak."))
      )
      y_label <- "Percentage of pre-crisis peak (100 = peak)"
      y_scale <- scale_y_continuous()
    }

    plot <- ggplot(yearly, aes(x = year, y = value, colour = area)) +
      annotate("rect", xmin = 2006.5, xmax = 2010.5,
               ymin = -Inf, ymax = Inf, fill = "grey85", alpha = 0.5) +
      annotate("text", x = 2008.5, y = Inf, label = "Downturn (2007-2010)",
               vjust = 1.5, colour = "grey30", size = 4.5) +
      geom_line(linewidth = 1.1) +
      geom_point(size = 2) +
      y_scale +
      labs(
        title = paste("How", measure_short[[input$measure]],
                      "changed in each chosen area"),
        subtitle = "Yearly averages; 2015 covers January to July only",
        x = "Year",
        y = y_label,
        colour = "Market area"
      ) +
      theme_minimal(base_size = 15) +
      theme(plot.title = element_text(face = "bold"),
            plot.title.position = "plot",
            panel.grid.minor = element_blank(),
            legend.position = "bottom")

    # With option 3 ticked, a dashed line marks the pre-crisis peak
    if (input$relative) {
      plot <- plot + geom_hline(yintercept = 100, linetype = "dashed",
                                colour = "grey40")
    }
    plot
  })

  # Inflation note: how adjusting for inflation changes the answer
  output$inflation_note <- renderText({
    nominal <- crisis_recovery(selected_data(), measure = "median") |>
      filter(status != "Insufficient data")
    real <- crisis_recovery(selected_data(), measure = "median_real") |>
      filter(status != "Insufficient data")
    if (nrow(real) == 0) {
      return("These areas don't have enough data to compare.")
    }
    paste0(
      "Why inflation matters: using prices as reported, ",
      sum(nominal$drop_pct < 0), " of ", nrow(nominal),
      " chosen areas fell below their pre-crisis peak. After adjusting for ",
      "inflation, ", sum(real$drop_pct < 0), " of ", nrow(real), " did. ",
      "Because prices in general rise over time, a home's price can look ",
      "steady while its real value is falling."
    )
  })

  # Summary table title, naming the chosen measure
  output$table_title <- renderText({
    paste("How far", measure_short[[input$measure]],
          "fell and when they recovered")
  })

  # Summary table: numbers right-aligned, units in the column headings
  output$recovery_table <- renderTable({
    unit <- measure_unit[[input$measure]]
    table <- selected_recovery() |>
      mutate(
        peak = ifelse(is.na(peak), NA, scales::comma(peak, accuracy = 1)),
        low = ifelse(is.na(low), NA, scales::comma(low, accuracy = 1)),
        peak_year = as.character(peak_year),
        low_year = as.character(low_year),
        recovery_year = as.character(recovery_year)
      ) |>
      select(area, peak_year, peak, low_year, low, drop_pct,
             recovery_year, status)
    names(table) <- c(
      "Area", "Peak year", paste("Pre-crisis peak", unit), "Low year",
      paste("Downturn low", unit), "Change (%)", "Back at peak in", "Status"
    )
    table
  }, align = "lrrrrrrl", digits = 1, na = "-")

  # Ranking chart: every area's fall, hardest hit at the top
  output$ranking_plot <- renderPlot({
    rec <- all_recovery()
    excluded <- rec$area[rec$status == "Insufficient data"]
    ranked <- rec |>
      filter(status != "Insufficient data") |>
      mutate(chosen = area %in% input$areas)

    ggplot(ranked, aes(x = drop_pct, y = reorder(area, -drop_pct),
                       fill = chosen)) +
      geom_col(width = 0.7) +
      geom_text(
        data = filter(ranked, chosen),
        aes(label = paste0(drop_pct, "%"),
            hjust = ifelse(drop_pct < 0, 1.15, -0.15)),
        size = 4.5, fontface = "bold"
      ) +
      geom_vline(xintercept = 0, colour = "grey40") +
      scale_x_continuous(labels = scales::label_percent(scale = 1),
                         expand = expansion(mult = 0.12)) +
      scale_fill_manual(
        values = c(`TRUE` = "#E67E22", `FALSE` = "grey80"),
        labels = c(`TRUE` = "Your chosen areas", `FALSE` = "Other areas"),
        name = NULL
      ) +
      labs(
        title = paste("How far", measure_short[[input$measure]],
                      "fell in every Texas market area"),
        subtitle = "Hardest hit at the top",
        x = "Change from pre-crisis peak to downturn low",
        y = NULL,
        caption = if (length(excluded) > 0) {
          paste("Not shown (no data before 2007):",
                paste(excluded, collapse = ", "))
        }
      ) +
      theme_minimal(base_size = 15) +
      theme(plot.title = element_text(face = "bold"),
            plot.title.position = "plot",
            panel.grid.minor = element_blank(),
            panel.grid.major.y = element_blank(),
            legend.position = "top",
            axis.text.y = element_text(size = 12))
  })
}

shinyApp(ui, server)

