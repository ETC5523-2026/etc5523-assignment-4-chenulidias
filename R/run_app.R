#' Launch the Texas housing crisis explorer
#'
#' Opens an interactive Shiny app for comparing how Texas housing markets
#' fell and recovered around the 2008 financial crisis.
#'
#' @return Called to launch the app; does not return a useful value.
#' @export
#' @examples
#' if (interactive()) {
#'   run_app()
#' }
run_app <- function() {
  app_dir <- system.file("app", package = "txhome")
  shiny::runApp(app_dir)
}
