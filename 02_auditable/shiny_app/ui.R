ui <- fluidPage(
  shinyFeedback::useShinyFeedback(),
  shinyjs::useShinyjs(),
  # Application Title
  titlePanel(
    h1("Shiny CRUD - Auditable", align = 'center'),
    windowTitle = "Shiny CRUD - Auditable"
  ),
  cars_table_module_ui("cars_table")
)

