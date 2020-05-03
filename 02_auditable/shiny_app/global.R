library(shiny)
library(DT)
library(dplyr)
library(DBI)
library(RSQLite)
library(shinyjs)
library(shinycssloaders)
library(shinydashboard)
library(lubridate)
library(shinyFeedback)


conn <- dbConnect(
  RSQLite::SQLite(),
  dbname = 'data/mtcars.sqlite3'
)

shiny::onStop(function() {
  dbDisconnect(conn)
})




# Turn off scientific notation
options(scipen = 999)

# Set spinner type (for loading)
options(spinner.type = 8)

# Create 'names_map' dataframe to convert variable names ('names') to clean
# column names ('display_names') in table (i.e. capitalized words, spaces, etc.)
names_map <- data.frame(
  names = c('model', 'mpg', 'cyl', 'disp', 'hp', 'drat', 'wt', 'qsec', 'vs',
            'am', 'gear', 'carb', 'created_at', 'created_by', 'modified_at', 'modified_by'),
  display_names = c('Model', 'Miles/Gallon', 'Cylinders', 'Displacement (cu.in.)',
                    'Horsepower', 'Rear Axle Ratio', 'Weight (lbs)', '1/4 Mile Time',
                    'Engine', 'Transmission', 'Forward Gears', 'Carburetors', 'Created At',
                    'Created By', 'Modified At', 'Modified By'),
  stringsAsFactors = FALSE
)



