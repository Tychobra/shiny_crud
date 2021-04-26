
#' Yssup Add & Edit Module
#'
#' Module to add & edit yssup in the yssup database file
#'
#' @importFrom shiny observeEvent showModal modalDialog removeModal fluidRow column textInput numericInput selectInput modalButton actionButton reactive eventReactive
#' @importFrom shinyFeedback showFeedbackDanger hideFeedback showToast
#' @importFrom shinyjs enable disable
#' @importFrom lubridate with_tz
#' @importFrom uuid UUIDgenerate
#' @importFrom DBI dbExecute
#'
#' @param modal_title string - the title for the modal
#' @param yssup_to_edit reactive returning a 1 row data frame of the yssup to edit
#' from the "yssup" table
#' @param modal_trigger reactive trigger to open the modal (Add or Edit buttons)
#'
#' @return None
#'
yssup_edit_module <- function(input, output, session, modal_title, yssup_to_edit, modal_trigger) {
  ns <- session$ns

  observeEvent(modal_trigger(), {
    hold <- yssup_to_edit()

    showModal(
      modalDialog(
        fluidRow(
          column(
            width = 6,
            selectInput(
              ns("anzilotti_antonio"),
              'Anzilotti Antonio',
              choices = c('scopata', 'baciata', 'niente'),
              selected = ifelse(is.null(hold), "", "niente")
            ),
            selectInput(
              ns('baldi_duccio'),
              'Baldi Duccio',
              choices = c('scopata', 'baciata', 'niente'),
              selected = ifelse(is.null(hold), "", "niente")
            ),
            selectInput(
              ns('benci_francesco'),
              'Benci Francesco',
              choices = c('Automatic', 'Manual'),
              choices = c('scopata', 'baciata', 'niente'),
              selected = ifelse(is.null(hold), "", "niente")
            ),
            selectInput(
              ns('benedetti_umberto'),
              'Benedetti Umberto',
              choices = c('scopata', 'baciata', 'niente'),
              selected = ifelse(is.null(hold), "", "niente")
            ),
            selectInput(
              ns('consiglio_giovanni'),
              'Consiglio Giovanni',
              choices = c('scopata', 'baciata', 'niente'),
              selected = ifelse(is.null(hold), "", "niente")
            ),
            selectInput(
              ns('fortuna_noah'),
              'Fortuna Noah',
              choices = c('scopata', 'baciata', 'niente'),
              selected = ifelse(is.null(hold), "", "niente")
            )
          ),
          column(
            width = 7,
            selectInput(
              ns('leoni_emanuele'),
              'Leoni Emanuele',
              choices = c('scopata', 'baciata', 'niente'),
              selected = ifelse(is.null(hold), "", "niente")
            ),
            selectInput(
              ns('maresi_matteo'),
              'Maresi Matteo',
              choices = c('scopata', 'baciata', 'niente'),
              selected = ifelse(is.null(hold), "", "niente")
            ),
            selectInput(
              ns('nardi_alessandro '),
              'Nardi Alessandro ',
              choices = c('scopata', 'baciata', 'niente'),
              selected = ifelse(is.null(hold), "", "niente")
            ),
            selectInput(
              ns('peggion_giacomo'),
              'Peggion Giacomo',
              choices = c('scopata', 'baciata', 'niente'),
              selected = ifelse(is.null(hold), "", "niente")
            ),
            selectInput(
              ns('piccini_cosimo'),
              'Piccini Cosimo',
              choices = c('scopata', 'baciata', 'niente'),
              selected = ifelse(is.null(hold), "", "niente")
            ),
            selectInput(
              ns('riessler_lorenzo'),
              'Riessler Lorenzo',
              choices = c('scopata', 'baciata', 'niente'),
              selected = ifelse(is.null(hold), "", "niente")
            ),
            selectInput(
              ns('scialdone_pietro'),
              'Scialdone Pietro',
              choices = c('scopata', 'baciata', 'niente'),
              selected = ifelse(is.null(hold), "", "niente")
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

    # Observe event for "Model" text input in Add/Edit yssup
    # `shinyFeedback`
    observeEvent(input$model, {
      if (input$model == "") {
        shinyFeedback::showFeedbackDanger(
          "model",
          text = "Must enter what you have donee!"
        )
        shinyjs::disable('submit')
      } else {
        shinyFeedback::hideFeedback("model")
        shinyjs::enable('submit')
      }
    })

  })





  edit_yssup_dat <- reactive({
    hold <- yssup_to_edit()

    out <- list(
      uid = if (is.null(hold)) NA else hold$uid,
      data = list(
        "anzilotti_antonio" = input$anzilotti_antonio,
        "baldi_duccio" = input$baldi_duccio,
        "benci_francesco" = input$benci_francesco,
        "benedetti_umberto" = input$benedetti_umberto,
        "consiglio_giovanni" = input$consiglio_giovanni,
        "fortuna_noah" = input$fortuna_noah,
        "leoni_emanuele" = input$leoni_emanuele,
        "maresi_matteo" = input$maresi_matteo,
        "nardi_alessandro" = input$nardi_alessandro,
        "peggion_giacomo" = input$peggion_giacomo,
        "piccini_cosimo" = input$piccini_cosimo,
        "riessler_lorenzo" = input$riessler_lorenzo,
        "scialdone_pietro" = input$scialdone_pietro
      )
    )

    time_now <- as.character(lubridate::with_tz(Sys.time(), tzone = "UTC"))

    if (is.null(hold)) {
      # adding a new yssup

      out$data$created_at <- time_now
      out$data$created_by <- session$userData$email
    } else {
      # Editing existing yssup

      out$data$created_at <- as.character(hold$created_at)
      out$data$created_by <- hold$created_by
    }

    out$data$modified_at <- time_now
    out$data$modified_by <- session$userData$email

    out
  })

  validate_edit <- eventReactive(input$submit, {
    dat <- edit_yssup_dat()

    # Logic to validate inputs...

    dat
  })

  observeEvent(validate_edit(), {
    removeModal()
    dat <- validate_edit()

    tryCatch({

      if (is.na(dat$uid)) {
        # creating a new yssup
        uid <- uuid::UUIDgenerate()

        dbExecute(
          conn,
          "INSERT INTO yssup (tipette, anzilotti_antonio, baldi_duccio, benci_francesco, benedetti_umberto,
          consiglio_giovanni, fortuna_noah, leoni_emanuele, maresi_matteo, nardi_alessandro, peggion_giacomo, 
          piccini_cosimo, riessler_lorenzo, scialdone_pietro , created_at, created_by, modified_at, modified_by) VALUES
          ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17)",
          params = c(
            list(uid),
            unname(dat$data)
          )
        )
      } else {
        # editing an existing yssup
        dbExecute(
          conn,
          "UPDATE yssup SET anzilotti_antonio=$1, baldi_duccio=$2, benci_francesco=$3, benedetti_umberto=$4, consiglio_giovanni=$5, fortuna_noah=$6,
          leoni_emanuele=$7, maresi_matteo=$8, nardi_alessandro=$9, peggion_giacomo=$10, piccini_cosimo=$11, riessler_lorenzo=$12, scialdone_pietro=$13,
          created_at=$14, created_by=$15, modified_at=$16, modified_by=$17 WHERE uid=$18",
          params = c(
            unname(dat$data),
            list(dat$uid)
          )
        )
      }

      session$userData$yssup_trigger(session$userData$yssup_trigger() + 1)
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
