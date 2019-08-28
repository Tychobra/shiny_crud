observeEvent(input$add_car, {
  req(session$userData$email == 'tycho.brahe@tychobra.com')
  showModal(
    modalDialog(
      fluidRow(
        column(
          width = 6,
          textInput('model', 'Model'),
          numericInput(
            'mpg',
            'Miles/Gallon',
            value = NULL,
            min = 0,
            step = 0.1
          ),
          numericInput(
            'cyl',
            'Cylinders',
            value = NULL,
            min = 0,
            max = 20,
            step = 1
          ),
          numericInput(
            'disp',
            'Displacement (cu.in.)',
            value = NULL,
            min = 0,
            step = 0.1
          ),
          numericInput(
            'hp',
            'Horsepower',
            value = NULL,
            min = 0,
            step = 1
          ),
          numericInput(
            'drat',
            'Rear Axle Ratio',
            value = NULL,
            min = 0,
            step = 0.01
          )
        ),
        column(
          width = 6,
          numericInput(
            'wt',
            'Weight (lbs)',
            value = NULL,
            min = 0,
            step = 1
          ),
          numericInput(
            'qsec',
            '1/4 Mile Time',
            value = NULL,
            min = 0,
            step = 0.01
          ),
          selectInput(
            'vs',
            'Engine',
            choices = c('Straight', 'V-shaped')
          ),
          selectInput(
            'am',
            'Transmission',
            choices = c('Automatic', 'Manual')
          ),
          numericInput(
            'gear',
            'Forward Gears',
            value = NULL,
            min = 0,
            step = 1
          ),
          numericInput(
            'carb',
            'Carburetors',
            value = NULL,
            min = 0,
            step = 1
          )
        )
      ),
      title = 'New Car Entry',
      size = 'm',
      footer = list(
        actionButton(
          'submit_add',
          'Submit',
          style="color: #fff; background-color: #07b710; border-color: #07b710",
          icon = icon("plus")
        ),
        modalButton('Cancel')
      )
    )
  )
})

new_car_dat <- reactive({
  list(
    'model' = input$model,
    'mpg' = input$mpg,
    'cyl' = input$cyl,
    'disp' = input$disp,
    'hp' = input$hp,
    'drat' = input$drat,
    'wt' = input$wt,
    'qsec' = input$qsec,
    'vs' = input$vs,
    'am' = input$am,
    'gear' = input$gear,
    'carb' = input$carb,
    'is_deleted' = FALSE
  )
})

validate_add <- eventReactive(input$submit_add, {
  dat <- new_car_dat()
  user_email <- session$userData$email
  
  dat$id <- digest::digest(c(dat, runif(1)))
  dat$modified_at <- NULL
  
  dat$created_by <- user_email
  dat$modified_by <- user_email
  
  dat
})

observeEvent(validate_add(), {
  removeModal()
  dat <- validate_add()
  
  tryCatch({
    
    tychobratools::add_row(
      conn,
      "mtcars",
      dat
    )
    
    # Show confirmation message
    session$sendCustomMessage(
      "show_toast",
      message = list(
        type = "success",
        title = "Car Successfully Added!",
        message = NULL
      )
    )
    
    car_trigger(car_trigger() + 1)
  }, error = function(error) {
    
    session$sendCustomMessage(
      "show_toast",
      message = list(
        type = "error",
        title = "Error Adding Car!",
        message = error
      )
    )
    
    print(error)
  })
  
})
