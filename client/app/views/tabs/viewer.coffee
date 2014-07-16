BaseView = require "../view"

module.exports = class View extends BaseView
  template: require("./templates/viewer")

  init: ->
    console.log "VIEWER", @options
