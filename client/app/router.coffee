AppHome = require("views/communityHome")
module.exports = Router = Backbone.Router.extend
  routes:
    "": "main"

  main: ->
    mainView = new AppHome({})
    mainView.render()
    return
