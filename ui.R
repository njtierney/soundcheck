library(shiny)
library(bslib)
library(DT)

page_sidebar(
  title = "Data Validation Tool",
  # Add custom CSS styling
  tags$head(
    tags$style(HTML("
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
  sidebar = sidebar(
    fileInput("file", "Upload CSV File",
              accept = c(".csv", ".xlsx")),
    checkboxInput("use_example", "Use Example Dataset", FALSE),
    hr(),
    downloadButton("download_notes", "Download Validation Notes")
  ),
  card(
    card_header("Data Table"),
    DTOutput("data_table")
  ),
  card(
    card_header("Validation Notes"),
    DTOutput("notes_table")
  )
)