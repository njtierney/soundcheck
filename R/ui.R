#' Soundcheck UI
#' @noRd
ui <- function() {
  bslib::page_sidebar(
    title = shiny::div(
      style = "display: flex; justify-content: space-between; align-items: center; width: 100%;",
      shiny::span("Data Validation Tool"),
      shiny::actionButton(
        "show_help",
        label = NULL,
        icon = shiny::icon("circle-question"),
        class = "btn-sm btn-outline-secondary",
        title = "Show help",
        style = "margin-right: 10px;"
      )
    ),
    shiny::tags$head(
      shiny::tags$style(shiny::HTML("
        /* Hover effect for table cells - light green */
        #data_table table.dataTable tbody td:hover {
          background-color: #90EE90 !important;
          cursor: pointer;
          transition: background-color 0.2s ease;
        }
        
        /* Vertical lines in data table */
        #data_table table.dataTable th,
        #data_table table.dataTable td {
          border-right: 1px solid #ddd;
        }
        
        /* Remove border from last column */
        #data_table table.dataTable th:last-child,
        #data_table table.dataTable td:last-child {
          border-right: none;
        }
      "))
    ),
    sidebar = bslib::sidebar(
      shiny::fileInput("file", "Upload CSV File",
                       accept = c(".csv", ".xlsx")),
      shiny::checkboxInput("use_example", "Use Example Dataset (mtcars)", TRUE),
      shiny::hr(),
      shiny::downloadButton("download_notes", "Download Validation Notes")
    ),
    bslib::layout_columns(
      col_widths = 12,
      bslib::navset_card_tab(
        bslib::nav_panel(
          "Data Table",
          DT::DTOutput("data_table")
        ),
        bslib::nav_panel(
          "Validation Notes",
          DT::DTOutput("notes_table")
        )
      )
    ),
  )
}
