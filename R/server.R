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
        shiny::tags$p(shiny::strong("Cell:"), glue::glue("Row {row}, Column {col_name}")),
        shiny::tags$p(shiny::strong("Current Value:"), as.character(value)),
        shiny::textInput("suggested_value", "Suggested Correction:",
                         width = "100%",
                         placeholder = "Enter corrected value (optional)"),
        shiny::textAreaInput("note_input", "Validation Note:",
                             width = "100%",
                             rows = 4,
                             placeholder = "Describe the issue or validation check"),
        footer = shiny::tagList(
          shiny::modalButton("Cancel"),
          shiny::actionButton("save_note", "Save Note", class = "btn-primary")
        )
      ))

      # Store current cell info
      rv$current_cell <- list(row = row, col = col_name, value = as.character(value))
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
      Suggested_Value = ifelse(is.null(input$suggested_value) || input$suggested_value == "",
                                "",
                                input$suggested_value),
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
      data.frame(Message = "No validation notes yet. Click on a cell to add a note.")
    } else {
      DT::datatable(
        rv$notes,
        options = list(pageLength = 5, scrollX = TRUE),
        rownames = FALSE
      )
    }
  })

  # Validation summary
  output$validation_summary <- shiny::renderText({
    paste(
      "Total cells checked:", nrow(rv$notes), "\n",
      "Unique rows flagged:", length(unique(rv$notes$Row)), "\n",
      "Unique columns flagged:", length(unique(rv$notes$Column))
    )
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