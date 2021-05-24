
app_name <- config::get(file = "yssup_crud/shiny_app/config.yml")$app_name
rsconnect::deployApp(
  appDir = "yssup_crud/shiny_app",
  account = "NiccoloSalvini",
  appName = app_name
)

