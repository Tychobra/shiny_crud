server <- function(input, output, session) {
  
  session$userData$email <- 'tycho.brahe@tychobra.com'
  
  source('server/01.1_s_car_table.R', local = TRUE)
  source('server/01.2_s_car_add.R', local = TRUE)
  source('server/01.3_s_car_edit.R', local = TRUE)
  source('server/01.4_s_car_delete.R', local = TRUE)
  
}
