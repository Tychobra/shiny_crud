library(RSQLite)
library(tibble)

# Create a connection object with SQLite
conn <- dbConnect(
  RSQLite::SQLite(),
  "01_traditional/shiny_app/data/mtcars.sqlite3"
)

# Create a query to prepare the 'mtcars' table with additional 'uid', 'id',
# & the 4 created/modified columns
create_mtcars_query = "CREATE TABLE mtcars (
  uid                             TEXT PRIMARY KEY,
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
  modified_by                     TEXT
)"

# dbExecute() executes a SQL statement with a connection object
# Drop the table if it already exists
dbExecute(conn, "DROP TABLE IF EXISTS mtcars")
# Execute the query created above
dbExecute(conn, create_mtcars_query)

# Read in the RDS file created in 'data_prep.R'
dat <- readRDS("01_traditional/data_prep/prepped/mtcars.RDS")

# add uid column to the `dat` data frame
dat$uid <- uuid::UUIDgenerate(n = nrow(dat))

# reorder the columns
dat <- dat %>%
  select(uid, everything())

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

# disconnect from SQLite before continuing
dbDisconnect(conn)
