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

# Create database connection
conn <- dbConnect(
  RSQLite::SQLite(),
  dbname = 'data/mtcars.sqlite3'
)

# Stop database connection when application stops
shiny::onStop(function() {
  dbDisconnect(conn)
})

# Turn off scientific notation
options(scipen = 999)

# Set spinner type (for loading)
options(spinner.type = 8)



