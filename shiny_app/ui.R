ui <- fluidPage(
  shiny::tags$head(
    tags$script(src = 'custom.js'),
    tags$script(src = "https://cdnjs.cloudflare.com/ajax/libs/toastr.js/latest/toastr.min.js"),
    tags$link(rel = "stylesheet", href = "https://cdnjs.cloudflare.com/ajax/libs/toastr.js/latest/toastr.min.css")
  ),
  shinyjs::useShinyjs(),
  # Application Title
  titlePanel(
    h1("Shiny CRUD Application", align = 'center'),
    windowTitle = "Shiny CRUD Application"
  ),
  
  # Main panel containing the table
  mainPanel(
    fluidRow(
      column(
        width = 2,
        actionButton(
          "add_car",
          "Add",
          style = "color: #fff; background-color: #07b710; border-color: #07b710",
          icon = icon('plus'),
          width = '100%'
        ) %>% hidden(),
        br(),
        br()
      )
    ),
    fluidRow(
      box(
      width = 12,
      #title = 'Motor Trend Car Road Tests Table',
      title = h3("Motor Trend Car Road Tests Table", align = 'center'),
      DTOutput('car_table') %>% withSpinner()
      )
    ),
    width = 12
  )
)
