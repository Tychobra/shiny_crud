
#' title
#'
#' detail goes here
#'
#' @param 
#'
#' @return
#'
car_delete_module <- function(input, output, session, modal_title, car_to_delete, modal_trigger) {
  ns <- session$ns
  # Observes trigger for this module (here, the Delete Button)
  observeEvent(modal_trigger(), {
    # Authorize who is able to access particular buttons (here, modules)
    req(session$userData$email == 'tycho.brahe@tychobra.com')
    hold <- car_to_delete()
    
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
  
  car_delete_prep <- reactive({
    hold <- car_to_delete()
    
    hold <- as.list(hold)
    
    hold$is_deleted <- TRUE
    hold$uid <- NULL
    hold$modified_at <- as.character(tychobratools::time_now_utc())
    hold$created_at <- as.character(hold$created_at)
    
    hold
  })
  
  observeEvent(input$delete_button, {
    removeModal()
    out <- car_delete_prep()
    
    tryCatch({
      
      tychobratools::add_row(
        session$userData$conn,
        "mtcars",
        out
      )
      
      session$userData$db_trigger(session$userData$db_trigger() + 1)
      tychobratools::show_toast("success", "Car Successfully Deleted")
    }, error = function(error) {
      
      tychobratools::show_toast("error", "Error Deleting Car")
      
      print(error)
    })
    
  })
  
}
