# Palmer penguins explorer
#
# A small, dependency-light Shiny app used in the workshop.
# It works both as a normal Shiny app (Run App) and exported with
# shinylive::export() to run in the browser.
#
# Data file penguins.csv is bundled next to this script.

library(shiny)
library(ggplot2)

# Read the bundled dataset once, at app build time.
penguins <- readr::read_csv("penguins.csv", show_col_types = FALSE)

format_variable_unit <- function(var_names, unit_mapping) {
  sapply(var_names, function(x) {
    # Find if any unit key matches the end of the variable name
    matched_key <- names(unit_mapping)[sapply(names(unit_mapping), function(k) grepl(paste0(k, "$"), x))]
    
    if (length(matched_key) > 0) {
      # Order matches by length descending to match the most specific unit first (e.g., 'mm' before 'm')
      matched_key <- matched_key[order(nchar(matched_key), decreasing = TRUE)][1]
      
      # Clean the prefix by removing the matched unit and any trailing separators (_, -, or camelCase boundaries)
      clean_name <- sub(paste0("([_-]?|(?<=[a-z])(?=[A-Z]))", matched_key, "$"), "", x, perl = TRUE)
    } else {
      clean_name <- x
    }

    # Add spaces back if it was camelCase (optional, e.g., 'maxLength' -> 'max Length')
    clean_name <- gsub("(?<=[a-z])(?=[A-Z])", " ", clean_name, perl = TRUE)
    clean_name <- gsub("[_-]", " ", clean_name) # Replace separators with spaces
    clean_name <- trimws(clean_name)            # Clean extra spaces
    clean_name <- stringr::str_to_title(clean_name)

    if (length(matched_key) > 0) {
      return(paste0(clean_name, " (", unit_mapping[[matched_key]], ")"))
    }
    
    # Return original if no unit match is found
    return(clean_name)
  }, USE.NAMES = FALSE)
}

# 1. Define your unit dictionary
my_units <- list(
  "mm" = "mm",
  "g" = "g"
)

ui <- fluidPage(
  titlePanel("Palmer penguins explorer"),

  sidebarLayout(
    sidebarPanel(
      selectInput(
        "variable", "Numeric variable",
        choices = c()
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
      readr::read_csv(input$data$datapath, show_col_types = FALSE)
    }
  })

  observe({
    bare_vars <- names(df())[sapply(df(), is.numeric)]
    names(bare_vars) <- format_variable_unit(bare_vars, my_units)
    updateSelectInput(
      session = session, 
      inputId = "variable", 
      choices = bare_vars
    )
  })

  output$hist <- renderPlot({
    req(input$variable)
    df() |>
      tidyr::drop_na() |> 
      ggplot(aes(.data[[input$variable]])) +
      geom_histogram(
        bins = input$bins, 
        fill = "#2E7D6B", 
        color = "white"
      ) +
      labs(
        x = format_variable_unit(input$variable, unit_mapping = my_units), 
        y = "Count", 
        title = "Histogram"
      )
  })

  output$summary <- renderTable({
    req(input$variable)
    df() |>
      dplyr::summarise(
        n    = dplyr::n(),
        mean = mean(.data[[input$variable]], na.rm = TRUE),
        sd   =   sd(.data[[input$variable]], na.rm = TRUE),
        min  =  min(.data[[input$variable]], na.rm = TRUE),
        max  =  max(.data[[input$variable]], na.rm = TRUE)
      )
  })
}

shinyApp(ui, server)
