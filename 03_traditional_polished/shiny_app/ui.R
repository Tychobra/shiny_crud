my_ui <- fluidPage(
  shinyFeedback::useShinyFeedback(),
  shinyjs::useShinyjs(),
  # Application Title
  titlePanel(
    h1("Shiny CRUD Application", align = 'center'),
    windowTitle = "Shiny CRUD Application"
  ),
  actionButton(
    "sign_out",
    "Sign Out",
    icon = icon("sign-out"),
    class = "pull-right"
  ),
  cars_table_module_ui("cars_table")
)

secure_ui(my_ui)

