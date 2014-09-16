# basic view to display a select box with the various options passed into it when defined

BaseView = require "./view"

module.exports = class View extends BaseView
  template: require("./templates/option")

  init: ->

  getRenderData: ->
    @options
