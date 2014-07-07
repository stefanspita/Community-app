# The function called from index.html
$(document).ready ->
  Swag.Config.partialsPath = './views/templates/'
  app = require("application")
  Router = require("router")
  Store = require "./models/store"
  app.store = new Store()
  app.router = new Router()
  Backbone.history.start()
  return
