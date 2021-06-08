fluidPage(
  shinyFeedback::useShinyFeedback(),
  shinyjs::useShinyjs(),
  # Application Title
  titlePanel(
    h1("Explore Yssup records", align = 'center'),
    windowTitle = "yssup database"
  ),
  yssup_table_module_ui("yssup_table")
)


