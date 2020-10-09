
#' Car Add & Edit Module
#'
#' Module to add & edit cars in the mtcars database file
#'
#' @importFrom shiny observeEvent showModal modalDialog removeModal fluidRow column textInput numericInput selectInput modalButton actionButton reactive eventReactive
#' @importFrom shinyFeedback showFeedbackDanger hideFeedback showToast
#' @importFrom shinyjs enable disable
#' @importFrom lubridate with_tz
#' @importFrom uuid UUIDgenerate
#' @importFrom DBI dbExecute
#'
#' @param modal_title string - the title for the modal
#' @param car_to_edit reactive returning a 1 row data frame of the car to edit
#' from the "mt_cars" table
#' @param modal_trigger reactive trigger to open the modal (Add or Edit buttons)
#'
#' @return None
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
              value = ifelse(is.null(hold), "", hold$model)
            ),
            numericInput(
              ns('mpg'),
              'Miles/Gallon',
              value = ifelse(is.null(hold), "", hold$mpg),
              min = 0,
              step = 0.1
            ),
            selectInput(
              ns('am'),
              'Transmission',
              choices = c('Automatic', 'Manual'),
              selected = ifelse(is.null(hold), "", hold$am)
            ),
            numericInput(
              ns('disp'),
              'Displacement (cu.in.)',
              value = ifelse(is.null(hold), "", hold$disp),
              min = 0,
              step = 0.1
            ),
            numericInput(
              ns('hp'),
              'Horsepower',
              value = ifelse(is.null(hold), "", hold$hp),
              min = 0,
              step = 1
            ),
            numericInput(
              ns('drat'),
              'Rear Axle Ratio',
              value = ifelse(is.null(hold), "", hold$drat),
              min = 0,
              step = 0.01
            )
          ),
          column(
            width = 6,
            numericInput(
              ns('wt'),
              'Weight (lbs)',
              value = ifelse(is.null(hold), "", hold$wt),
              min = 0,
              step = 1
            ),
            numericInput(
              ns('qsec'),
              '1/4 Mile Time',
              value = ifelse(is.null(hold), "", hold$qsec),
              min = 0,
              step = 0.01
            ),
            selectInput(
              ns('vs'),
              'Engine',
              choices = c('Straight', 'V-shaped'),
              selected = ifelse(is.null(hold), "", hold$vs)
            ),
            numericInput(
              ns('cyl'),
              'Cylinders',
              value = ifelse(is.null(hold), "", hold$cyl),
              min = 0,
              max = 20,
              step = 1
            ),
            numericInput(
              ns('gear'),
              'Forward Gears',
              value = ifelse(is.null(hold), "", hold$gear),
              min = 0,
              step = 1
            ),
            numericInput(
              ns('carb'),
              'Carburetors',
              value = ifelse(is.null(hold), "", hold$carb),
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
            class = "btn btn-primary",
            style = "color: white"
          )
        )
      )
    )

    # Observe event for "Model" text input in Add/Edit Car Modal
    # `shinyFeedback`
    observeEvent(input$model, {
      if (input$model == "") {
        shinyFeedback::showFeedbackDanger(
          "model",
          text = "Must enter model of car!"
        )
        shinyjs::disable('submit')
      } else {
        shinyFeedback::hideFeedback("model")
        shinyjs::enable('submit')
      }
    })

  })





  edit_car_dat <- reactive({
    hold <- car_to_edit()

    out <- list(
      uid = if (is.null(hold)) NA else hold$uid,
      data = list(
        "model" = input$model,
        "mpg" = input$mpg,
        "cyl" = input$cyl,
        "disp" = input$disp,
        "hp" = input$hp,
        "drat" = input$drat,
        "wt" = input$wt,
        "qsec" = input$qsec,
        "vs" = input$vs,
        "am" = input$am,
        "gear" = input$gear,
        "carb" = input$carb
      )
    )

    time_now <- as.character(lubridate::with_tz(Sys.time(), tzone = "UTC"))

    if (is.null(hold)) {
      # adding a new car

      out$data$created_at <- time_now
      out$data$created_by <- session$userData$email
    } else {
      # Editing existing car

      out$data$created_at <- as.character(hold$created_at)
      out$data$created_by <- hold$created_by
    }

    out$data$modified_at <- time_now
    out$data$modified_by <- session$userData$email

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

      if (is.na(dat$uid)) {
        # creating a new car
        uid <- uuid::UUIDgenerate()

        dbExecute(
          conn,
          "INSERT INTO mtcars (uid, model, mpg, cyl, disp, hp, drat, wt, qsec, vs, am,
          gear, carb, created_at, created_by, modified_at, modified_by) VALUES
          ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17)",
          params = c(
            list(uid),
            unname(dat$data)
          )
        )
      } else {
        # editing an existing car
        dbExecute(
          conn,
          "UPDATE mtcars SET model=$1, mpg=$2, cyl=$3, disp=$4, hp=$5, drat=$6,
          wt=$7, qsec=$8, vs=$9, am=$10, gear=$11, carb=$12, created_at=$13, created_by=$14,
          modified_at=$15, modified_by=$16 WHERE uid=$17",
          params = c(
            unname(dat$data),
            list(dat$uid)
          )
        )
      }

      session$userData$mtcars_trigger(session$userData$mtcars_trigger() + 1)
      showToast("success", paste0(modal_title, " Successs"))
    }, error = function(error) {

      msg <- paste0(modal_title, " Error")


      # print `msg` so that we can find it in the logs
      print(msg)
      # print the actual error to log it
      print(error)
      # show error `msg` to user.  User can then tell us about error and we can
      # quickly identify where it cam from based on the value in `msg`
      showToast("error", msg)
    })
  })

}
