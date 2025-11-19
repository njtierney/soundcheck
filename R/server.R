#' Soundcheck Server
#' @noRd
server <- function(input, output, session) {
  # Reactive values to store data and notes
  rv <- shiny::reactiveValues(
    data = NULL,
    notes = data.frame(
      Row = integer(),
      Column = character(),
      Value = character(),
      Note = character(),
      Suggested_Value = character(),
      Timestamp = character(),
      stringsAsFactors = FALSE
    )
  )
  
  # Show welcome modal on load
  shiny::observe({
    shiny::showModal(shiny::modalDialog(
      title = shiny::div(
        " Welcome to Soundcheck!"
      ),
      shiny::tags$p(
        "A lightweight app to help you perform quality control on your data."
      ),
      shiny::tags$h5("How to use:"),
      shiny::tags$ol(
        shiny::tags$li("Upload your CSV file or use the example dataset"),
        shiny::tags$li("Browse through your data in the table"),
        shiny::tags$li(shiny::strong("Click on any cell"), " to add a validation note"),
        shiny::tags$li("Describe any changes or questions you have about that cell"),
        shiny::tags$li("Optionally suggest a corrected value"),
        shiny::tags$li("Download your validation notes when complete")
      ),
      shiny::tags$p(
        shiny::tags$em(
          "Tip: Hover over cells to see them highlight in green. ",
          "Click the ", shiny::icon("circle-question"), " button in the top right to view this help again."
        )
      ),
      size = "m",
      easyClose = TRUE,
      footer = shiny::modalButton("Got it!")
    ))
  }) |> 
    shiny::bindEvent(session$clientData, once = TRUE)
  
  # Show help modal when help button is clicked
  shiny::observeEvent(input$show_help, {
    shiny::showModal(shiny::modalDialog(
      title = shiny::div(
        shiny::icon("circle-question", style = "color: #90EE90; font-size: 1.5em;"),
        " How to Use Soundcheck"
      ),
      shiny::tags$h5("Getting Started:"),
      shiny::tags$ol(
        shiny::tags$li("Upload your CSV file or use the example dataset"),
        shiny::tags$li("Browse through your data in the table"),
        shiny::tags$li(shiny::strong("Click on any cell"), " to add a validation note"),
        shiny::tags$li("Describe any changes or questions you have about that cell"),
        shiny::tags$li("Optionally suggest a corrected value"),
        shiny::tags$li("Download your validation notes when complete")
      ),
      shiny::tags$h5("Features:"),
      shiny::tags$ul(
        shiny::tags$li("Hover over cells to see them highlight in green"),
        shiny::tags$li("Track which cells have been reviewed"),
        shiny::tags$li("View validation summary statistics"),
        shiny::tags$li("Export all notes as a timestamped CSV file")
      ),
      size = "m",
      easyClose = TRUE,
      footer = shiny::modalButton("Close")
    ))
  })

  # Load data
  shiny::observe({
    if (input$use_example) {
      rv$data <- mtcars
    } else if (!is.null(input$file)) {
      rv$data <- read.csv(input$file$datapath)
    }
  })

  # Render data table
  output$data_table <- DT::renderDT({
    shiny::req(rv$data)
    DT::datatable(
      rv$data,
      selection = list(mode = "single", target = "cell"),
      options = list(
        pageLength = 10,
        scrollX = TRUE
      )
    )
  })

  # Handle cell selection
  shiny::observeEvent(input$data_table_cells_selected, {
    cell <- input$data_table_cells_selected
    if (length(cell) > 0) {
      row <- cell[1]
      col <- cell[2]
      value <- rv$data[row, col]
      col_name <- colnames(rv$data)[col]

      shiny::showModal(shiny::modalDialog(
        title = "Add Validation Note",
        shiny::tags$p(
          shiny::strong("Cell:"),
          glue::glue("Row {row}, Column {col_name}")
        ),
        shiny::tags$p(shiny::strong("Current Value:"), as.character(value)),
        shiny::textInput(
          "suggested_value",
          "Suggested Correction:",
          width = "100%",
          placeholder = "Enter corrected value (optional)"
        ),
        shiny::textAreaInput(
          "note_input",
          "Validation Note:",
          width = "100%",
          rows = 4,
          placeholder = "Describe the issue or validation check"
        ),
        footer = shiny::tagList(
          shiny::modalButton("Cancel"),
          shiny::actionButton("save_note", "Save Note", class = "btn-primary")
        )
      ))

      # Store current cell info
      rv$current_cell <- list(
        row = row,
        col = col_name,
        value = as.character(value)
      )
    }
  })

  # Save note
  shiny::observeEvent(input$save_note, {
    shiny::req(rv$current_cell, input$note_input)

    new_note <- data.frame(
      Row = rv$current_cell$row,
      Column = rv$current_cell$col,
      Value = rv$current_cell$value,
      Note = input$note_input,
      Suggested_Value = ifelse(
        is.null(input$suggested_value) || input$suggested_value == "",
        "",
        input$suggested_value
      ),
      Timestamp = format(Sys.time(), "%Y-%m-%d %H:%M:%S"),
      stringsAsFactors = FALSE
    )

    rv$notes <- rbind(rv$notes, new_note)
    shiny::removeModal()
    shiny::showNotification("Note saved successfully!", type = "message")
  })

  # Render notes table
  output$notes_table <- DT::renderDT({
    if (nrow(rv$notes) == 0) {
      data.frame(
        Message = "No validation notes yet. Click on a cell to add a note."
      )
    } else {
      DT::datatable(
        rv$notes,
        options = list(pageLength = 5, scrollX = TRUE),
        rownames = FALSE
      )
    }
  })

  # Download notes
  output$download_notes <- shiny::downloadHandler(
    filename = function() {
      glue::glue("validation_notes_{format(Sys.Date(), '%Y%m%d')}.csv")
    },
    content = function(file) {
      write.csv(rv$notes, file, row.names = FALSE)
    }
  )
}
