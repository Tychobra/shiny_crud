# Library in packages used in this application
library(shiny)
library(DT)
library(DBI)
library(RSQLite)
library(shinyjs)
library(shinycssloaders)
library(lubridate)
library(shinyFeedback)
library(dplyr)
library(dbplyr)
library(polished)

db_config <- config::get()$db

# Create database connection
conn <- dbConnect(
  RSQLite::SQLite(),
  dbname = db_config$dbname
)

polished_config(
  app_name = "03_traditional_polished",
  api_key = "<your polished.tech API key>"
)

# Stop database connection when application stops
shiny::onStop(function() {
  dbDisconnect(conn)
})

# Turn off scientific notation
options(scipen = 999)

# Set spinner type (for loading)
options(spinner.type = 8)
