car_to_edit <- reactiveVal(NULL)

observeEvent(input$car_row_to_edit, {
  row_num <- as.numeric(input$car_row_to_edit)
  
  out <- car_filter()[row_num, ]
  
  car_to_edit(out)
}, priority = 1)

observeEvent(input$car_row_to_edit, {
  req(car_to_edit(), session$userData$email == 'tycho.brahe@tychobra.com')
  hold <- car_to_edit()
  
  showModal(
    modalDialog(
      fluidRow(
        column(
          width = 6,
          textInput(
            'edit_model',
            'Model',
            value = if (is.na(hold$model)) "" else hold$model
          ),
          numericInput(
            'edit_mpg',
            'Miles/Gallon',
            value = if (is.na(hold$mpg)) "" else hold$mpg,
            min = 0,
            step = 0.1
          ),
          numericInput(
            'edit_cyl',
            'Cylinders',
            value = if (is.na(hold$cyl)) "" else hold$cyl,
            min = 0,
            max = 20,
            step = 1
          ),
          numericInput(
            'edit_disp',
            'Displacement (cu.in.)',
            value = if (is.na(hold$disp)) "" else hold$disp,
            min = 0,
            step = 0.1
          ),
          numericInput(
            'edit_hp',
            'Horsepower',
            value = if (is.na(hold$hp)) "" else hold$hp,
            min = 0,
            step = 1
          ),
          numericInput(
            'edit_drat',
            'Rear Axle Ratio',
            value = if (is.na(hold$drat)) "" else hold$drat,
            min = 0,
            step = 0.01
          )
        ),
        column(
          width = 6,
          numericInput(
            'edit_wt',
            'Weight (lbs)',
            value = if (is.na(hold$wt)) "" else hold$wt,
            min = 0,
            step = 1
          ),
          numericInput(
            'edit_qsec',
            '1/4 Mile Time',
            value = if (is.na(hold$qsec)) "" else hold$qsec,
            min = 0,
            step = 0.01
          ),
          selectInput(
            'edit_vs',
            'Engine',
            choices = c('Straight', 'V-shaped'),
            selected = if (is.na(hold$vs)) "" else hold$vs
          ),
          selectInput(
            'edit_am',
            'Transmission',
            choices = c('Automatic', 'Manual'),
            selected = if (is.na(hold$am)) "" else hold$am
          ),
          numericInput(
            'edit_gear',
            'Forward Gears',
            value = if (is.na(hold$gear)) "" else hold$gear,
            min = 0,
            step = 1
          ),
          numericInput(
            'edit_carb',
            'Carburetors',
            value = if (is.na(hold$carb)) "" else hold$carb,
            min = 0,
            step = 1
          )
        )
      ),
      title = 'Edit Car Entry',
      size = 'm',
      footer = list(
        actionButton(
          'submit_edit',
          'Submit',
          style="color: #fff; background-color: #07b710; border-color: #07b710",
          icon = icon("plus")
        ),
        modalButton('Cancel')
      )
    )
  )
})

edit_car_dat <- reactive({
  hold <- car_to_edit()
  hold$uid <- NULL
  
  new_vals <- list(
    'model' = input$edit_model,
    'mpg' = input$edit_mpg,
    'cyl' = input$edit_cyl,
    'disp' = input$edit_disp,
    'hp' = input$edit_hp,
    'drat' = input$edit_drat,
    'wt' = input$edit_wt,
    'qsec' = input$edit_qsec,
    'vs' = input$edit_vs,
    'am' = input$edit_am,
    'gear' = input$edit_gear,
    'carb' = input$edit_carb
  )
  
  modifyList(hold, new_vals)
})

validate_edit <- eventReactive(input$submit_edit, {
  dat <- edit_car_dat()
  
  dat$modified_at <- NULL
  dat$modified_by <- session$userData$email
  
  dat
})

observeEvent(validate_edit(), {
  removeModal()
  dat <- validate_edit()
  
  tryCatch({
    
    tychobratools::add_row(
      conn,
      "mtcars",
      dat
    )
    
    # display a successful toast message
    session$sendCustomMessage(
      "show_toast",
      message = list(
        type = "success",
        title = "Car Successfully edited!",
        message = NULL
      )
    )
    
    car_trigger(car_trigger() + 1)
  }, error = function(error) {
    
    session$sendCustomMessage(
      "show_toast",
      message = list(
        type = "error",
        title = "Error Editing Car",
        message = error
      )
    )
    
    #print("[ TYCHOBRA ERROR ] location edit error")
    print(error)
  })
})
