#' Run the Soundcheck Shiny App
#'
#' Launch the data validation Shiny application.
#'
#' @param ... Additional arguments passed to \code{\link[shiny]{shinyApp}}
#'
#' @return A Shiny app object
#' @export
#'
#' @examples
#' \dontrun{
#' run_app()
#' }
run_app <- function(...) {
  shiny::shinyApp(ui = ui(), server = server, ...)
}