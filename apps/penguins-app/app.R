# Palmer penguins explorer
#
# A small, dependency-light Shiny app used in the workshop.
# It works both as a normal Shiny app (Run App) and exported with
# shinylive::export() to run in the browser.
#
# Data file penguins.csv is bundled next to this script.

library(shiny)
library(dplyr)
library(ggplot2)
library(readr)

# Read the bundled dataset once, at app build time.
penguins <- read_csv("penguins.csv", show_col_types = FALSE)

ui <- fluidPage(
  titlePanel("Palmer penguins explorer"),

  sidebarLayout(
    sidebarPanel(
      selectInput(
        "variable", "Numeric variable",
        choices = c("bill_length_mm", "bill_depth_mm", "flipper_length_mm", "body_mass_g")
      ),
      sliderInput("bins", "Number of bins", min = 5, max = 40, value = 20),
      fileInput("data", "Upload your own CSV (optional)", accept = ".csv")
    ),
    mainPanel(
      plotOutput("hist"),
      tableOutput("summary")
    )
  )
)

server <- function(input, output, session) {
  # Use the uploaded file if provided, otherwise the bundled dataset.
  df <- reactive({
    if (is.null(input$data)) {
      penguins
    } else {
      read_csv(input$data$datapath, show_col_types = FALSE)
    }
  })

  output$hist <- renderPlot({
    req(input$variable)
    df() |>
      ggplot(aes(.data[[input$variable]])) +
      geom_histogram(bins = input$bins, fill = "#2E7D6B", color = "white") +
      labs(x = input$variable, y = "count", title = "Histogram")
  })

  output$summary <- renderTable({
    req(input$variable)
    df() |>
      summarise(
        n = n(),
        mean = mean(.data[[input$variable]], na.rm = TRUE),
        sd   = sd(.data[[input$variable]], na.rm = TRUE),
        min  = min(.data[[input$variable]], na.rm = TRUE),
        max  = max(.data[[input$variable]], na.rm = TRUE)
      )
  })
}

shinyApp(ui, server)
