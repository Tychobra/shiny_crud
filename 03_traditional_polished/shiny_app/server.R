my_server <- function(input, output, session) {

  observeEvent(input$sign_out, {

    sign_out_from_shiny()
    session$reload()

  })

  # Call the server function portion of the `cars_table_module.R` module file
  callModule(
    cars_table_module,
    "cars_table"
  )
}

secure_server(my_server)
