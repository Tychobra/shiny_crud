
#' Yssup Delete Module
#'
#' This module is for deleting a row's information from the yssup database file
#'
#' @importFrom shiny observeEvent req showModal h3 modalDialog removeModal actionButton modalButton
#' @importFrom DBI dbExecute
#' @importFrom shinyFeedback showToast
#'
#' @param modal_title string - the title for the modal
#' @param yssup_to_delete string - the model of the yssup to be deleted
#' @param modal_trigger reactive trigger to open the modal (Delete button)
#'
#' @return None
#'
yssup_delete_module <- function(input, output, session, modal_title, yssup_to_delete, modal_trigger) {
  ns <- session$ns
  # Observes trigger for this module (here, the Delete Button)
  observeEvent(modal_trigger(), {
    # Authorize who is able to access particular buttons (here, modules)
    req(session$userData$email == 'niccolo.salvini27@gmail.com')

    showModal(
      modalDialog(
        div(
          style = "padding: 30px;",
          class = "text-center",
          h2(
            style = "line-height: 1.75;",
            paste0(
              'Are you sure you want to delete the "',
              yssup_to_delete()$tipette,
              '"?'
            )
          )
        ),
        title = modal_title,
        size = "m",
        footer = list(
          modalButton("Cancel"),
          actionButton(
            ns("submit_delete"),
            "Delete yssup",
            class = "btn-danger",
            style="color: #fff;"
          )
        )
      )
    )
  })

  observeEvent(input$submit_delete, {
    req(yssup_to_delete())

    removeModal()

    tryCatch({

      uid <- yssup_to_delete()$uid

      DBI::dbExecute(
        conn,
        "DELETE FROM yssup WHERE uid=$1",
        params = c(uid)
      )

      session$userData$yssup_trigger(session$userData$yssup_trigger() + 1)
      showToast("success", "yssup Successfully Deleted")
    }, error = function(error) {

      msg <- "Error Deleting yssup"
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
