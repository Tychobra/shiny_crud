# import image from https://hub.docker.com/u/rocker/
FROM rocker/shiny:latest

# system libraries of general use
RUN apt-get update -qq && apt-get -y --no-install-recommends install \
    libxml2-dev \
    libcairo2-dev \
    libsqlite3-dev \
    libmariadbd-dev \
    libpq-dev \
    libssh2-1-dev \
    unixodbc-dev \
    libcurl4-openssl-dev \
    libssl-dev

## update system libraries
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get clean

    
# Download and install library
RUN R -e "install.packages(c('shiny','config',  'DT', 'DBI', 'RSQLite', 'shinyjs', 'shinycssloaders', 'lubridate', 'shinyFeedback','dplyr', 'dbplyr'))"

# copy the app to the image
COPY shiny_app /root/app

# make all app files readable (solves issue when dev in Windows, but building in Ubuntu)
RUN chmod -R 755 /root/app

# expose port
EXPOSE 3838

# run entrypoint
CMD ["R", "-e", "shiny::runApp('/root/app',  host = '0.0.0.0', port = 3838)"]

