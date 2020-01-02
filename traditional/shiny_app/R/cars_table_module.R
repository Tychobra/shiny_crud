#' cars_table_module.R
#'
#' The module for displaying the mtcars datatable
#'
#' @param id The id for this module
#'
#'
#' @importFrom shiny NS tagList fluidRow column actionButton br
#' @importFrom DT DTOutput
#' @importFrom htmltools tags
#' @importFrom shinycssloaders withSpinner
#'
#'
cars_table_module_ui <- function(id) {
  ns <- NS(id)

  tagList(
    fluidRow(
      column(
        width = 2,
        actionButton(
          ns("add_car"),
          "Add",
          class = "btn-success",
          style = "color: #fff;",
          icon = icon('plus'),
          width = '100%'
        ),
        tags$br(),
        tags$br()
      )
    ),
    fluidRow(
      column(
        width = 12,
        title = "Motor Trend Car Road Tests",
        DTOutput(ns('car_table')) %>%
          withSpinner(),
        tags$br(),
        tags$br()
      )
    ),
    tags$script(src = "cars_table_module.js"),
    tags$script(paste0("cars_table_module_js('", ns(''), "')"))
  )
}

cars_table_module <- function(input, output, session) {

  # read in "mtcars" table from the database
  cars <- reactive({
    session$userData$db_trigger()

    session$userData$conn %>%
      tbl('mtcars') %>%
      collect() %>%
      mutate(
        created_at = as.POSIXct(created_at, tz = "UTC"),
        modified_at = as.POSIXct(modified_at, tz = "UTC")
      ) %>%
      arrange(desc(modified_at))

  })


  car_table_prep <- reactiveVal(NULL)

  observeEvent(cars(), {
    out <- cars()

    ids <- out$uid

    actions <- purrr::map_chr(ids, function(id_) {
      paste0(
        '<div class="btn-group" style="width: 75px;" role="group" aria-label="Basic example">
          <button class="btn btn-primary btn-sm edit_btn" data-toggle="tooltip" data-placement="top" title="Edit" id = ', id_, ' style="margin: 0"><i class="fa fa-pencil-square-o"></i></button>
          <button class="btn btn-danger btn-sm delete_btn" data-toggle="tooltip" data-placement="top" title="Delete" id = ', id_, ' style="margin: 0"><i class="fa fa-trash-o"></i></button>
        </div>'
      )
    })

    # remove the uid column.  We don't want to show this column to the user
    out <- out %>%
      select(-uid)

    # set the row action buttons to the first column of the mtcars table
    out <- cbind(
      tibble(" " = actions),
      out
    )

    if (is.null(car_table_prep())) {
      # loading data into the table for the first time, so we render the entire table
      # rather than using a DT proxy
      car_table_prep(out)

    } else {

      # table has already rendered, so use DT proxy to update the data in the
      # table without rerendering the entire table
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
      class = "compact stripe row-border nowrap",
      # Escape the HTML in all except 1st column (which has the buttons)
      escape = -1,
      extensions = c("Buttons"),
      options = list(
        scrollX = TRUE,
        dom = 'Bftip',
        buttons = list(
          list(
            extend = "excel",
            text = "Download",
            title = paste0("mtcars-", Sys.Date()),
            exportOptions = list(
              columns = 1:(length(out) - 1)
            )
          )
        ),
        columnDefs = list(
          list(targets = 0, orderable = FALSE)
        )
      )
    ) %>%
      formatDate(
        columns = c("created_at", "modified_at"),
        method = 'toLocaleString'
      )

  })

  car_table_proxy <- DT::dataTableProxy('car_table')

  callModule(
    car_edit_module,
    "add_car",
    modal_title = "Add Car",
    car_to_edit = function() NULL,
    modal_trigger = reactive({input$add_car})
  )

  car_to_edit <- eventReactive(input$car_id_to_edit, {

    cars() %>%
      filter(uid == input$car_id_to_edit)
  })

  callModule(
    car_edit_module,
    "edit_car",
    modal_title = "Edit Car",
    car_to_edit = car_to_edit,
    modal_trigger = reactive({input$car_id_to_edit})
  )

  car_to_delete <- eventReactive(input$car_id_to_delete, {

    cars() %>%
      filter(uid == input$car_id_to_delete)
  })

  callModule(
    car_delete_module,
    "delete_car",
    modal_title = "Delete Car",
    car_to_delete = car_to_delete,
    modal_trigger = reactive({input$car_id_to_delete})
  )

}
