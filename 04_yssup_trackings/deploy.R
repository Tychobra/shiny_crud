
app_name <- config::get(file = "04_yssup_trackings/shiny_app/config.yml")$app_name
rsconnect::deployApp(
  appDir = "04_yssup_trackings/shiny_app",
  account = "tychobra",
  appName = app_name
)

