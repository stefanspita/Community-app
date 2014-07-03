AppHome = require("views/communityHome")
module.exports = class Router extends Backbone.Router
  routes:
    "": "main"

  main: ->
    mainView = new AppHome({})
    mainView.render()
    return
