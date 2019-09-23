car_to_delete <- reactiveVal(NULL)

observeEvent(input$car_row_to_delete, {
  row_num <- as.numeric(input$car_row_to_delete)

  out <- car_filter()[row_num, ]

  car_to_delete(out)
}, priority = 1)

observeEvent(input$car_row_to_delete, {
  req(session$userData$email == 'tycho.brahe@tychobra.com')
  dat <- car_to_delete()

  showModal(
    modalDialog(
      h3(
        "Are you sure you want to delete this information?"
      ),
      title = "Delete Car Entry",
      size = "m",
      footer = list(
        actionButton(
          "delete_button",
          "Delete Car",
          style="color: #fff; background-color: #dd4b39; border-color: #d73925"),
        modalButton("Cancel")
      )
    )
  )
})

car_delete_prep <- reactive({
  req(car_to_delete())

  dat <- car_to_delete()

  dat <- as.list(dat)

  dat$is_deleted <- TRUE
  dat$uid <- NULL
  dat$modified_at <- NULL
  dat$created_at <- as.character(dat$created_at)

  dat
})

observeEvent(input$delete_button, {
  removeModal()
  dat <- car_delete_prep()

  tryCatch({

    tychobratools::add_row(
      conn,
      "mtcars",
      dat
    )

    car_trigger(car_trigger() + 1)
    toastr_success("Car Successfully Deleted")
  }, error = function(error) {

    toastr_error("Error Deleting Car")

    print(error)
  })

})
