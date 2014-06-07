# The function called from index.html
$(document).ready ->
  Swag.Config.partialsPath = './views/templates/'
  app = require("application")
  app.initialize()
  return
