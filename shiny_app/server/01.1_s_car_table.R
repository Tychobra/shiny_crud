observe({
  if (session$userData$email == "tycho.brahe@tychobra.com") shinyjs::show("add_car")
})

car_data <- reactiveVal(NULL)
# Trigger to reload data from database
car_trigger <- reactiveVal(0)

observe({
  car_trigger()
  
  out <- conn %>%
    tbl('mtcars') %>%
    collect() %>%
    group_by(id) %>%
    filter(modified_at == max(modified_at)) %>%
    ungroup() %>%
    arrange(desc(modified_at))
  
  car_data(out)
})

car_filter <- reactive({
  req(car_data())
  
  out <- car_data()
  
  out <- out %>%
    filter(is_deleted == FALSE)
  
  out
})

car_table_prep <- reactiveVal(NULL)

observeEvent(car_filter(), {
  out <- car_filter()
  
  out <- out %>%
    select(-uid, -id, -is_deleted)
  
  if (session$userData$email == 'tycho.brahe@tychobra.com') {
    if (nrow(out) == 0) {
      actions <- character(0)
    } else {
      rows <- 1:nrow(out)
      
      actions <- paste0(
        '<div class="btn-group" style="width: 75px;" role="group" aria-label="Basic example">
            <button class="btn btn-primary btn-sm edit_btn" data-toggle="tooltip" data-placement="top" title="Edit Car" id = ', rows, ' style="margin: 0"><i class="fa fa-pencil-square-o"></i></button>
            <button class="btn btn-danger btn-sm delete_btn" data-toggle="tooltip" data-placement="top" title="Delete Car" id = ', rows, ' style="margin: 0"><i class="fa fa-trash-o"></i></button></div>'
      )
      
      out <- cbind(
        tibble(`Edit/Delete` = actions),
        out
      )
    }
  }
  
  # Change column names from variable -> human readable
  names(out) <- convert_column_names(names(out), names_map)
  
  if (is.null(car_table_prep())) {
    car_table_prep(out)
  } else {
    replaceData(car_table_proxy, out, resetPaging = FALSE, rownames = FALSE)
  }
  
})

output$car_table <- renderDT({
  req(car_table_prep())
  out <- car_table_prep()
  
  datatable(
    out,
    rownames = FALSE,
    selection = "none",
    # Escape the HTML in all except 1st column (which has the buttons)
    escape = -1,
    extensions = c("Buttons"),
    options = list(
      scrollX = TRUE,
      dom = 'Blftip',
      columnDefs = list(
        list(targets = 0, orderable = FALSE)
      )
    )
  )
}, server = TRUE)

car_table_proxy <- DT::dataTableProxy('car_table')
