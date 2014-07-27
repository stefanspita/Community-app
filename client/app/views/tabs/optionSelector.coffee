BaseView = require "../view"

module.exports = class View extends BaseView
  template: require("./templates/optionSelector")

  events:
    "click .remove":"removeOption"

  getRenderData: ->
    @options

  removeOption: (e) ->
    option = $(e.target).data("group")
    delete @store.filter[@options.key][option]
    Backbone.trigger "filterReset"