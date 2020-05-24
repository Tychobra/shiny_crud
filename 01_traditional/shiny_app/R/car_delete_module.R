
#' Car Delete Module
#'
#' This module is for deleting a row's information from the mtcars database file
#'
#' @importFrom  shiny observeEvent req showModal h3 modalDialog removeModal actionButton modalButton
#' @importFrom DBI dbExecute
#' @importFrom shinytoastr toastr_success toastr_error
#'
#' @param modal_title string - the title for the modal
#' @param car_to_delete string - the model of the car to be deleted
#' @param modal_trigger reactive trigger to open the modal (Delete button)
#'
#' @return None

car_delete_module <- function(input, output, session, modal_title, car_to_delete, modal_trigger) {
  ns <- session$ns
  # Observes trigger for this module (here, the Delete Button)
  observeEvent(modal_trigger(), {
    # Authorize who is able to access particular buttons (here, modules)
    req(session$userData$email == 'tycho.brahe@tychobra.com')

    showModal(
      modalDialog(
        div(
          style = "padding: 30px;",
          class = "text-center",
          h2(
            style = "line-height: 1.75;",
            paste0(
              'Are you sure you want to delete the "',
              car_to_delete()$model,
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
            "Delete Car",
            class = "btn-danger",
            style="color: #fff;"
          )
        )
      )
    )
  })

  observeEvent(input$submit_delete, {
    req(car_to_delete())

    removeModal()

    tryCatch({

      uid <- car_to_delete()$uid

      DBI::dbExecute(
        conn,
        "DELETE FROM mtcars WHERE uid=$1",
        params = c(uid)
      )

      session$userData$mtcars_trigger(session$userData$mtcars_trigger() + 1)
      showToast("success", "Car Successfully Deleted")
    }, error = function(error) {

      showToast("error", "Error Deleting Car")

      print(error)
    })
  })
}
