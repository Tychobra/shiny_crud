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
            width = 7,
            textInput(
              ns("tipette"),
              'Tipetta',
              value = hold$tipette
            ),
            selectInput(
              ns("anzilotti_antonio"),
              'Anzilotti Antonio',
              choices = c('scopata', 'baciata', 'niente'),
              selected = ifelse(is.null(hold), "", hold$anzilotti_antonio)
            ),
            selectInput(
              ns('baldi_duccio'),
              'Baldi Duccio',
              choices = c('scopata', 'baciata', 'niente'),
              selected = ifelse(is.null(hold), "", hold$baldi_duccio)
            ),
            selectInput(
              ns('benci_francesco'),
              'Benci Francesco',
              choices = c('scopata', 'baciata', 'niente'),
              selected = ifelse(is.null(hold), "",hold$benci_francesco )
            ),
            selectInput(
              ns('benedetti_umberto'),
              'Benedetti Umberto',
              choices = c('scopata', 'baciata', 'niente'),
              selected = ifelse(is.null(hold), "", hold$benedetti_umberto)
            ),
            selectInput(
              ns('consiglio_giovanni'),
              'Consiglio Giovanni',
              choices = c('scopata', 'baciata', 'niente'),
              selected = ifelse(is.null(hold), "", hold$consiglio_giovanni)
            ),
            selectInput(
              ns('fortuna_noah'),
              'Fortuna Noah',
              choices = c('scopata', 'baciata', 'niente'),
              selected = ifelse(is.null(hold), "", hold$fortuna_noah)
            )
          ),
          column(
            width = 7,
            selectInput(
              ns('leoni_emanuele'),
              'Leoni Emanuele',
              choices = c('scopata', 'baciata', 'niente'),
              selected = ifelse(is.null(hold), "",hold$leoni_emanuele)
            ),
            selectInput(
              ns('maresi_matteo'),
              'Maresi Matteo',
              choices = c('scopata', 'baciata', 'niente'),
              selected = ifelse(is.null(hold), "", hold$maresi_matteo)
            ),
            selectInput(
              ns('nardi_alessandro'),
              'Nardi Alessandro',
              choices = c('scopata', 'baciata', 'niente'),
              selected = ifelse(is.null(hold), "", hold$nardi_alessandro)
            ),
            selectInput(
              ns('peggion_giacomo'),
              'Peggion Giacomo',
              choices = c('scopata', 'baciata', 'niente'),
              selected = ifelse(is.null(hold), "", hold$peggion_giacomo)
            ),
            selectInput(
              ns('piccini_cosimo'),
              'Piccini Cosimo',
              choices = c('scopata', 'baciata', 'niente'),
              selected = ifelse(is.null(hold), "", hold$piccini_cosimo)
            ),
            selectInput(
              ns('riessler_lorenzo'),
              'Riessler Lorenzo',
              choices = c('scopata', 'baciata', 'niente'),
              selected = ifelse(is.null(hold), "", hold$riessler_lorenzo)
            ),
            selectInput(
              ns('scialdone_pietro'),
              'Scialdone Pietro',
              choices = c('scopata', 'baciata', 'niente'),
              selected = ifelse(is.null(hold), "", hold$scialdone_pietro)
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
        "tipette" = input$tipette,
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
          "INSERT INTO yssup (
          uid, tipette, anzilotti_antonio, baldi_duccio, benci_francesco, benedetti_umberto,
          consiglio_giovanni, fortuna_noah, leoni_emanuele, maresi_matteo, nardi_alessandro,
          peggion_giacomo, piccini_cosimo, riessler_lorenzo, scialdone_pietro , created_at, 
          created_by, modified_at, modified_by) VALUES
          ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17, $18, $19)",
          params = c(
            list(uid),
            unname(dat$data)
          )
        )
      } else {
        # editing an existing yssup
        dbExecute(
          conn,
          "UPDATE yssup SET tipette = $1, anzilotti_antonio=$2, baldi_duccio=$3, benci_francesco=$4, benedetti_umberto=$5, consiglio_giovanni=$6, fortuna_noah=$7,
          leoni_emanuele=$8, maresi_matteo=$9, nardi_alessandro=$10, peggion_giacomo=$11, piccini_cosimo=$12, riessler_lorenzo=$13, scialdone_pietro=$14,
          created_at=$15, created_by=$16, modified_at=$17, modified_by=$18 WHERE uid=$19",
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
