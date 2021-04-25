function(input, output, session) {

  # Use session$userData to store user data that will be needed throughout
  # the Shiny application
  session$userData$email <- 'tycho.brahe@tychobra.com'

  # Call the server function portion of the `cars_table_module.R` module file
  callModule(
    cars_table_module,
    "cars_table"
  )
}
