server <- function(input, output, session) {

  session$userData$email <- 'tycho.brahe@tychobra.com'
  session$userData$conn <- conn
  session$userData$db_trigger <- reactiveVal(0)

  callModule(
    cars_table_module,
    "cars_table"
  )
}
