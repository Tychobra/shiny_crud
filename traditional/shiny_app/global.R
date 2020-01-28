# Library in packages used in this application
library(shiny)
library(DT)
library(dplyr)
library(DBI)
library(RSQLite)
library(shinyjs)
library(shinycssloaders)
library(shinyWidgets)
library(shinydashboard)
library(lubridate)
library(shinytoastr)
library(shinyFeedback)

db_config <- config::get()$db

# Create database connection
conn <- dbConnect(
  RSQLite::SQLite(),
  dbname = db_config$db_name
)

# Stop database connection when application stops
shiny::onStop(function() {
  dbDisconnect(conn)
})

# Turn off scientific notation
options(scipen = 999)

# Set spinner type (for loading)
options(spinner.type = 8)
