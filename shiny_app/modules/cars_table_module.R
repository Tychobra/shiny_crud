cars_table_module_css <- function(ns) {

  paste0("#", ns('car_table'), " {
    white-space: nowrap;
  }")
}

cars_table_module_ui <- function(id) {
  ns <- NS(id)

  tagList(
    tags$head(
      tags$style(
        cars_table_module_css(ns)
      )
    ),
    fluidRow(
      column(
        width = 2,
        actionButton(
          ns("add_car"),
          "Add",
          style = "color: #fff; background-color: #07b710; border-color: #07b710",
          icon = icon('plus'),
          width = '100%'
        ) %>% hidden(),
        br(),
        br()
      )
    ),
    fluidRow(
      column(
        width = 12,
        title = h3("Motor Trend Car Road Tests Table", align = 'center'),
        DTOutput(ns('car_table')) %>% withSpinner(),
        br(),
        br()
      )
    ),
    tags$script(src = "cars_table_module.js"),
    tags$script(paste0("cars_table_module_js('", ns(''), "')"))
  )
}



cars_table_module <- function(input, output, session) {
  observe({
    if (session$userData$email == "tycho.brahe@tychobra.com") shinyjs::show("add_car")
  })


  # Trigger to reload data from database
  car_trigger <- reactiveVal(0)

  car_data <- reactive({
    session$userData$db_trigger()

    session$userData$conn %>%
      tbl('mtcars') %>%
      collect() %>%
      mutate(
        created_at = as.POSIXct(created_at, tz = "UTC"),
        modified_at = as.POSIXct(modified_at, tz = "UTC")
      ) %>%
      group_by(id) %>%
      filter(modified_at == max(modified_at)) %>%
      ungroup() %>%
      arrange(desc(modified_at))

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
    ) %>%
      formatDate(
        columns = c("Created At", "Modified At"),
        # params = list(
        #   year = 'numeric',
        #   month = 'long',
        #   day = 'numeric'
        # )
        method = 'toLocaleString'
      )
  }, server = TRUE)

  car_table_proxy <- DT::dataTableProxy('car_table')

  callModule(
    car_edit_module,
    "add_car",
    modal_title = "Add Car",
    car_to_edit = function() NULL,
    modal_trigger = reactive({input$add_car})
  )

  car_to_edit <- reactiveVal(NULL)

  observeEvent(input$car_row_to_edit, {
    row_num <- as.numeric(input$car_row_to_edit)

    out <- car_filter()[row_num, ]

    car_to_edit(out)
  }, priority = 1)

  callModule(
    car_edit_module,
    "edit_car",
    modal_title = "Edit Car",
    car_to_edit = car_to_edit,
    modal_trigger = reactive({input$car_row_to_edit})
  )
}