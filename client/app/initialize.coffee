# The function called from index.html
$(document).ready ->
  Swag.Config.partialsPath = './views/templates/'
  app = require("application")
  storeInit = require "./models/store"
  Router = require("router")
  app.router = new Router()
  Backbone.history.start()
  return
