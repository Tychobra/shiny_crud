server <- function(input, output, session) {

  session$userData$email <- 'tycho.brahe@tychobra.com'
  session$userData$conn <- conn
  session$userData$db_trigger <- reactiveVal(0)

  #source('server/01.1_s_car_table.R', local = TRUE)
  callModule(
    cars_table_module,
    "cars_table"
  )
}
