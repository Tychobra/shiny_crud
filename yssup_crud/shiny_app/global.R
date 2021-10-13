# Library in packages used in this application
library(shiny, quietly = T, warn.conflicts = F)
library(DT, quietly = T, warn.conflicts = F)
library(DBI, quietly = T, warn.conflicts = F)
library(RSQLite, quietly = T, warn.conflicts = F)
library(shinyjs, quietly = T, warn.conflicts = F)
library(shinycssloaders, quietly = T, warn.conflicts = F)
library(lubridate, quietly = T, warn.conflicts = F)
library(shinyFeedback, quietly = T, warn.conflicts = F)
library(dplyr, quietly = T, warn.conflicts = F)
library(dbplyr, quietly = T, warn.conflicts = F)
library(RPostgres, quietly = T, warn.conflicts = F)


# db_config <- config::get()$db


conn <- dbConnect(RPostgres::Postgres(),
                  dbname = "d48t7csiftocvo", 
                  host='ec2-52-19-96-181.eu-west-1.compute.amazonaws.com', 
                  port="5432", 
                  user="udknpypytovowv", 
                  password="6c19e250350d95a8f6fbf83c3bd83ce19e701f6be6497c08a0f943c1021c357f")  


# # Create database connection
# conn <- dbConnect(
#   RSQLite::SQLite(),
#   dbname = db_config$dbname
# )

# Stop database connection when application stops
shiny::onStop(function() {
  dbDisconnect(conn)
})

# Turn off scientific notation
options(scipen = 999)

# Set spinner type (for loading)  
options(spinner.type = 8)
