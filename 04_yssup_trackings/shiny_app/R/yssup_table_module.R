#' Yssup Table Module UI
#'
#' The UI portion of the module for displaying the yssup datatable
#'
#' @importFrom shiny NS tagList fluidRow column actionButton tags
#' @importFrom DT DTOutput
#' @importFrom shinycssloaders withSpinner
#'
#' @param id The id for this module
#'
#' @return a \code{shiny::\link[shiny]{tagList}} containing UI elements
#'
yssup_table_module_ui <- function(id) {
  ns <- NS(id)

  tagList(
    fluidRow(
      column(
        width = 2,
        actionButton(
          ns("add_yssup"),
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
        DTOutput(ns('yssup_table')) %>%
          withSpinner(),
        tags$br(),
        tags$br()
      )
    ),
    tags$script(src = "yssup_table_module.js"),
    tags$script(paste0("yssup_table_module_js('", ns(''), "')"))
  )
}

#' Yssup Table Module Server
#'
#' The Server portion of the module for displaying the yssup datatable
#'
#' @importFrom shiny reactive reactiveVal observeEvent req callModule eventReactive
#' @importFrom DT renderDT datatable replaceData dataTableProxy
#' @importFrom dplyr tbl collect mutate arrange select filter pull
#' @importFrom purrr map_chr
#' @importFrom tibble tibble
#'
#' @param None
#'
#' @return None

yssup_table_module <- function(input, output, session) {

  # trigger to reload data from the "yssup" table
  session$userData$yssup_trigger <- reactiveVal(0)

  # Read in "yssup" table from the database
  yssup <- reactive({
    session$userData$yssup_trigger()

    out <- NULL
    tryCatch({
      out <- conn %>%
        tbl('yssup') %>%
        collect() %>%
        mutate(
          created_at = as.POSIXct(created_at, tz = "UTC"),
          modified_at = as.POSIXct(modified_at, tz = "UTC")
        ) %>%
        arrange(desc(modified_at))
    }, error = function(err) {


      msg <- "Database Connection Error"
      # print `msg` so that we can find it in the logs
      print(msg)
      # print the actual error to log it
      print(error)
      # show error `msg` to user.  User can then tell us about error and we can
      # quickly identify where it cam from based on the value in `msg`
      showToast("error", msg)
    })

    out
  })


  yssup_table_prep <- reactiveVal(NULL)

  observeEvent(yssup(), {
    out <- yssup()

    ids <- out$uid

    actions <- purrr::map_chr(ids, function(id_) {
      paste0(
        '<div class="btn-group" style="width: 75px;" role="group" aria-label="Basic example">
          <button class="btn btn-primary btn-sm edit_btn" data-toggle="tooltip" data-placement="top" title="Edit" id = ', id_, ' style="margin: 0"><i class="fa fa-pencil-square-o"></i></button>
          <button class="btn btn-danger btn-sm delete_btn" data-toggle="tooltip" data-placement="top" title="Delete" id = ', id_, ' style="margin: 0"><i class="fa fa-trash-o"></i></button>
        </div>'
      )
    })

    # Remove the `uid` column. We don't want to show this column to the user
    out <- out %>%
      select(-uid)

    # Set the Action Buttons row to the first column of the `yssup` table
    out <- cbind(
      tibble(" " = actions),
      out
    )

    if (is.null(yssup_table_prep())) {
      # loading data into the table for the first time, so we render the entire table
      # rather than using a DT proxy
      yssup_table_prep(out)

    } else {

      # table has already rendered, so use DT proxy to update the data in the
      # table without rerendering the entire table
      replaceData(yssup_table_proxy, out, resetPaging = FALSE, rownames = FALSE)

    }
  })

  output$yssup_table <- renderDT({
    req(yssup_table_prep())
    out <- yssup_table_prep()

    datatable(
      out,
      # rownames = c(
      #   "Arianna Presciutti", "Blandina Allegra", "Bulgarini Ginevra",
      #   "Ciaramella Cecilia", "Curelli Chiara", " Disa Lucrezia",
      #   "Fallani Margherita", " Fanfani Bianca", " Galli Lucrezia",
      #   "Galullo Francesca", "Godereccia Ortigia", "Gramigni Margherita",
      #   "Iandelli Rebecca", "Iavicoli Giulia", "Lega Irene",
      #   "Maggia Lidia", "Manini Giulia", "Marchi Margherita",
      #   "Marra Gaia", "Martinelli Elena", "Mengoni Matilde",
      #   "Milli Caterina", "Molesti Camilla", "O Braian Tara",
      #   "Paoletti Bianca", "Presciutti Ester", "Quercetti Giulia",
      #   "Sottili Sofia", "Tagliafraschi Gaia", "De Vittorio Luna",
      #   "Cioni Bianca", "Borri Lucrezia"
      # ),
      # colnames = c('Anzilotti Antonio', 'Baldi Duccio', 'Benci Francesco', 'Benedetti Umberto',
      #              'Consiglio Giovanni', 'Fortuna Noah', 'Leoni Emanuele', 'Maresi Matteo',
      #              'Nardi Alessandro', 'Peggion Giacomo', 'Piccini Cosimo', 'Riessler Lorenzo', 'Scialdone Pietro',
      #              'Created At', 'Created By', 'Modified At', 'Modified By'),
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
            title = paste0("yssup-", Sys.Date()),
            exportOptions = list(
              columns = 1:(length(out) - 1)
            )
          )
        ),
        columnDefs = list(
          list(targets = 0, orderable = FALSE)
        ),
        drawCallback = JS("function(settings) {
          // removes any lingering tooltips
          $('.tooltip').remove()
        }")
      )
    ) %>%
      formatDate(
        columns = c("created_at", "modified_at"),
        method = 'toLocaleString'
      )

  })

  yssup_table_proxy <- DT::dataTableProxy('yssup_table')

  callModule(
    yssup_edit_module,
    "add_yssup",
    modal_title = "Add Yssup",
    yssup_to_edit = function() NULL,
    modal_trigger = reactive({input$add_yssup})
  )

  yssup_to_edit <- eventReactive(input$yssup_id_to_edit, {

    yssup() %>%
      filter(uid == input$yssup_id_to_edit)
  })

  callModule(
    yssup_edit_module,
    "edit_yssup",
    modal_title = "Edit Yssup",
    yssup_to_edit = yssup_to_edit,
    modal_trigger = reactive({input$yssup_id_to_edit})
  )

  yssup_to_delete <- eventReactive(input$yssup_id_to_delete, {

    out <- yssup() %>%
      filter(uid == input$yssup_id_to_delete) %>%
      as.list()
  })

  callModule(
    yssup_delete_module,
    "delete_yssup",
    modal_title = "Delete Yssup",
    yssup_to_delete = yssup_to_delete,
    modal_trigger = reactive({input$yssup_id_to_delete})
  )

}
