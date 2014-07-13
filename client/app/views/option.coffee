BaseView = require "./view"

module.exports = class View extends BaseView
  template: require("./templates/option")

  events:
    "click a.delete": "deleteOption"

  init: ->

  getRenderData: ->
    @options

  deleteOption: ->
    @remove()
    Backbone.trigger 'filterOption:removed'
    return