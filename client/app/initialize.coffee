# The function called from index.html
$(document).ready ->
  Swag.registerHelpers()
  app = require("application")
  Router = require("router")
  Store = require "./models/store"
  app.store = new Store()
  app.store.filter = {groupings:{}, filters:{}, attributes:{}, sorter:{}}
  app.router = new Router()
  Backbone.history.start()
  return
