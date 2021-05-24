function(input, output, session) {

  # Use session$userData to store user data that will be needed throughout
  # the Shiny application
  session$userData$email <- 'niccolo.salvini27@gmail.com'
  print(getwd())

  # Call the server function portion of the `yssup_table_module.R` module file
  callModule(
    yssup_table_module,
    "yssup_table"
  )
}
