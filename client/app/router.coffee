# There is only one main template in the application. The "communityHome" view is the starting view

AppHome = require("views/communityHome")

module.exports = class Router extends Backbone.Router
  routes:
    "": "main"

  main: ->
    mainView = new AppHome({})
    mainView.render()
    return
