
#' title
#'
#' detail goes here
#'
#' @param modal_title string - the title for the modal
#' @param car_to_edit reactive returning a 1 row data frame of the car to edit
#' from the "mt_cars" table
#' @param model_trigger reactive trigger to open the modal
#'
#'
#' @importFrom shiny showModal modalDialog fluidRow column textInput numericInput selectInput modalButton actionButton reactive
#' @importClassesFrom digest digest
#'
car_edit_module <- function(input, output, session, modal_title, car_to_edit, modal_trigger) {
  ns <- session$ns

  observeEvent(modal_trigger(), {
    hold <- car_to_edit()

    showModal(
      modalDialog(
        fluidRow(
          column(
            width = 6,
            textInput(
              ns("model"),
              'Model',
              value = if (is.null(hold)) "" else hold$model
            ),
            numericInput(
              ns('mpg'),
              'Miles/Gallon',
              value = if (is.null(hold)) "" else hold$mpg,
              min = 0,
              step = 0.1
            ),
            numericInput(
              ns('cyl'),
              'Cylinders',
              value = if (is.null(hold)) "" else hold$cyl,
              min = 0,
              max = 20,
              step = 1
            ),
            numericInput(
              ns('disp'),
              'Displacement (cu.in.)',
              value = if (is.null(hold)) "" else hold$disp,
              min = 0,
              step = 0.1
            ),
            numericInput(
              ns('hp'),
              'Horsepower',
              value = if (is.null(hold)) "" else hold$hp,
              min = 0,
              step = 1
            ),
            numericInput(
              ns('drat'),
              'Rear Axle Ratio',
              value = if (is.null(hold)) "" else hold$drat,
              min = 0,
              step = 0.01
            )
          ),
          column(
            width = 6,
            numericInput(
              ns('wt'),
              'Weight (lbs)',
              value = if (is.null(hold)) "" else hold$wt,
              min = 0,
              step = 1
            ),
            numericInput(
              ns('qsec'),
              '1/4 Mile Time',
              value = if (is.null(hold)) "" else hold$qsec,
              min = 0,
              step = 0.01
            ),
            selectInput(
              ns('vs'),
              'Engine',
              choices = c('Straight', 'V-shaped'),
              selected = if (is.null(hold)) "" else hold$vs
            ),
            selectInput(
              ns('am'),
              'Transmission',
              choices = c('Automatic', 'Manual'),
              selected = if (is.null(hold)) "" else hold$am
            ),
            numericInput(
              ns('gear'),
              'Forward Gears',
              value = if (is.null(hold)) "" else hold$gear,
              min = 0,
              step = 1
            ),
            numericInput(
              ns('carb'),
              'Carburetors',
              value = if (is.null(hold)) "" else hold$carb,
              min = 0,
              step = 1
            )
          )
        ),
        title = modal_title,
        size = 'm',
        footer = list(
          modalButton('Cancel'),
          actionButton(
            ns('submit'),
            'Submit',
            class = "btn-success",
            style="color: #fff;",
            icon = icon("plus")
          )
        )
      )
    )
  })

  edit_car_dat <- reactive({
    hold <- car_to_edit()

    new_vals <- list(
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
      'carb' = input$carb
    )

    new_vals$modified_by <- session$userData$email
    new_vals$modified_at <- as.character(tychobratools::time_now_utc())


    if (is.null(hold)) {
      # adding a new car
      out <- new_vals
      out$created_at <- as.character(tychobratools::time_now_utc())
      out$created_by <- session$userData$email
      out$id <- digest::digest(new_vals)
    } else {

      new_vals$created_by <- hold$created_by
      new_vals$created_at <- as.character(hold$created_at)

      # editing an existing car
      out <- modifyList(hold, new_vals)
    }

    out
  })

  validate_edit <- eventReactive(input$submit, {
    dat <- edit_car_dat()

    # Logic to validate inputs...

    dat
  })

  observeEvent(validate_edit(), {
    removeModal()
    dat <- validate_edit()

    tryCatch({

      tychobratools::add_row(
        session$userData$conn,
        "mtcars",
        dat
      )

      session$userData$db_trigger(session$userData$db_trigger() + 1)
      tychobratools::show_toast("success", paste0(modal_title, " Success"))
    }, error = function(error) {

      tychobratools::show_toast("error", "Error Editing Car")

      print(error)
    })
  })

}
