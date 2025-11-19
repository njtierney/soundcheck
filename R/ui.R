#' Soundcheck UI
#' @noRd
ui <- function() {
  bslib::page_sidebar(
    title = "Data Validation Tool",
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
      shiny::checkboxInput("use_example", "Use Example Dataset", FALSE),
      shiny::hr(),
      shiny::downloadButton("download_notes", "Download Validation Notes")
    ),
    bslib::card(
      bslib::card_header("Data Table"),
      DT::DTOutput("data_table")
    ),
    bslib::card(
      bslib::card_header("Validation Summary"),
      shiny::verbatimTextOutput("validation_summary")
    ),
    bslib::card(
      bslib::card_header("Validation Notes"),
      DT::DTOutput("notes_table")
    )
  )
}