# The function called from index.html
$(document).ready ->
  Swag.registerHelpers()
  app = require("application")
  Router = require("router")
  Store = require "./models/store"
  app.store = new Store()
  app.store.filter = {groupings:{}, filters:{}, attributes:[], sorter:{}}
  app.router = new Router()
  Backbone.history.start()
  window.onbeforeunload = ->
    return "Going back to the previous page will exit this website. Data will have to be reloaded on re-entering it."
  return
