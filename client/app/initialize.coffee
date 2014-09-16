# When the DOM is ready, load the Backbone application
$(document).ready ->
  Swag.registerHelpers()
  app = require("application")

  # Backbone router
  Router = require("router")
  app.router = new Router()

  # A model to store the data used by the client in
  Store = require "./models/store"
  app.store = new Store()
  app.store.filter = {groupings:{}, filters:{}, attributes:[], sorter:{}}

  Backbone.history.start()
  window.onbeforeunload = ->
    return "Going back to the previous page will exit this website. Data will have to be reloaded on re-entering it."
  return
