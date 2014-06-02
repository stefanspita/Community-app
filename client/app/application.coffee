module.exports = initialize: ->
  Router = require("router")
  @router = new Router()
  Backbone.history.start()
  return