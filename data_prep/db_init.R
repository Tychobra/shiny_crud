library(RSQLite)
#library(DBI)
#library(config)
library(tibble)

# Set the configuration environment to work with either the development (default)
# database, or the production database (for actual deployment)
# NOTE: NO config.yml file at the moment (connected to SQLite & using .sqlite file)
# Sys.setenv("R_CONFIG_ACTIVE" = "default")
# #Sys.setenv("R_CONFIG_ACTIVE" = "production")
#
# db_config <- config::get(file = 'shiny_app/config.yml')

# Create a connection object with SQLite
conn <- dbConnect(RSQLite::SQLite(), 'shiny_app/data/mtcars.sqlite3')

# Create a query to prepare the 'mtcars' table with additional 'uid', 'id',
# & the 4 created/modified columns
create_mtcars_query = "CREATE TABLE mtcars (
  uid                             SERIAL PRIMARY KEY,
  id                              TEXT,
  model                           TEXT,
  mpg                             REAL,
  cyl                             REAL,
  disp                            REAL,
  hp                              REAL,
  drat                            REAL,
  wt                              REAL,
  qsec                            REAL,
  vs                              TEXT,
  am                              TEXT,
  gear                            REAL,
  carb                            REAL,
  created_at                      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_by                      TEXT,
  modified_at                     TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  modified_by                     TEXT,
  is_deleted                      BOOLEAN DEFAULT 0
)"

# dbExecute() executes a SQL statement with a connection object
# Drop the table if it already exists
dbExecute(conn, "DROP TABLE IF EXISTS mtcars")
# Execute the query created above
dbExecute(conn, create_mtcars_query)

# Read in the RDS file created in 'data_prep.R'
dat <- readRDS("data_prep/prepped/mtcars.RDS")

# Create 'id' column in 'dat' dataframe
ids <- lapply(1:nrow(dat), function(row_num) {
  row_data <- digest::digest(dat[row_num, ])
})

dat$id <- unlist(ids)

# Fill in the SQLite table with the values from the RDS file
DBI::dbWriteTable(
  conn,
  name = "mtcars",
  value = dat,
  overwrite = FALSE,
  append = TRUE
)

# List tables to confirm 'mtcars' table exists
dbListTables(conn)

# MUST disconnect from SQLite before continuing
dbDisconnect(conn)

