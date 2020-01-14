
#' Car Delete Module
#'
#' This module is for deleting a row's information from the mtcars database file
#'
#' @param 
#'
#' @return
#' 
#' @importFrom  shiny showModal observeEvent modalDialog actionButton modalButton observeEvent
#'
car_delete_module <- function(input, output, session, modal_title, car_to_delete, modal_trigger) {
  ns <- session$ns
  # Observes trigger for this module (here, the Delete Button)
  observeEvent(modal_trigger(), {
    # Authorize who is able to access particular buttons (here, modules)
    req(session$userData$email == 'tycho.brahe@tychobra.com')
    
    showModal(
      modalDialog(
        h3(
          "Are you sure you want to delete this information?"
        ),
        title = modal_title,
        size = "m",
        footer = list(
          actionButton(
            ns("delete_button"),
            "Delete Car",
            style="color: #fff; background-color: #dd4b39; border-color: #d73925"),
          modalButton("Cancel")
        )
      )
    )
  })
  
  observeEvent(input$delete_button, {
    req(modal_trigger())
    
    removeModal()
    
    tryCatch({

      uid <- as.character(modal_trigger())

      DBI::dbExecute(
        session$userData$conn,
        "DELETE FROM mtcars WHERE uid=$1",
        params = c(uid)
      )
      
      session$userData$db_trigger(session$userData$db_trigger() + 1)
      shinytoastr::toastr_success("Car Successfully Deleted")
    }, error = function(error) {
      
      shinytoastr::toastr_error("Error Deleting Car")
      
      print(error)
    })
  })
}
