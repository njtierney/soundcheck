library(shiny)
library(DT)
library(glue)

function(input, output, session) {
  # Reactive values to store data and notes
  rv <- reactiveValues(
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
  observe({
    if (input$use_example) {
      rv$data <- mtcars
    } else if (!is.null(input$file)) {
      rv$data <- read.csv(input$file$datapath)
    }
  })
  
  # Render data table
  output$data_table <- renderDT({
    req(rv$data)
    datatable(
      rv$data,
      selection = list(mode = "single", target = "cell"),
      options = list(
        pageLength = 10,
        scrollX = TRUE
      )
    )
  })
  
  # Handle cell selection
  observeEvent(input$data_table_cells_selected, {
    cell <- input$data_table_cells_selected
    if (length(cell) > 0) {
      row <- cell[1]
      col <- cell[2]
      value <- rv$data[row, col]
      col_name <- colnames(rv$data)[col]
      
      showModal(modalDialog(
        title = "Add Validation Note",
        tags$p(strong("Cell:"), glue("Row {row}, Column {col_name}")),
        tags$p(strong("Current Value:"), as.character(value)),
        textInput("suggested_value", "Suggested Correction:", 
                  width = "100%", 
                  placeholder = "Enter corrected value (optional)"),
        textAreaInput("note_input", "Validation Note:", 
                      width = "100%", 
                      rows = 4,
                      placeholder = "Describe the issue or validation check"),
        footer = tagList(
          modalButton("Cancel"),
          actionButton("save_note", "Save Note", class = "btn-primary")
        )
      ))
      
      # Store current cell info
      rv$current_cell <- list(row = row, col = col_name, value = as.character(value))
    }
  })
  
  # Save note
  observeEvent(input$save_note, {
    req(rv$current_cell, input$note_input)
    
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
    removeModal()
    showNotification("Note saved successfully!", type = "message")
  })
  
  # Render notes table
  output$notes_table <- renderDT({
    if (nrow(rv$notes) == 0) {
      data.frame(Message = "No validation notes yet. Click on a cell to add a note.")
    } else {
      datatable(
        rv$notes,
        options = list(pageLength = 5, scrollX = TRUE),
        rownames = FALSE
      )
    }
  })
  
  # Download notes
  output$download_notes <- downloadHandler(
    filename = function() {
      glue("validation_notes_{format(Sys.Date(), '%Y%m%d')}.csv")
    },
    content = function(file) {
      write.csv(rv$notes, file, row.names = FALSE)
    }
  )
}