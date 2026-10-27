library(shiny)
library(bslib)
library(dplyr)
library(ggplot2)
library(txhome)

ui <- page_sidebar(
  title = "Texas housing markets and the 2008 crisis",
  sidebar = sidebar(
    "Controls will go here"
  ),
  "Outputs will go here"
)

server <- function(input, output, session) {
}

shinyApp(ui, server)
