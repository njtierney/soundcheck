library(shiny)
library(bslib)
library(DT)

page_sidebar(
  title = "Data Validation Tool",
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
    card_header("Validation Summary"),
    verbatimTextOutput("validation_summary")
  ),
  card(
    card_header("Validation Notes"),
    DTOutput("notes_table")
  )
)