BaseView = require "../view"

module.exports = class View extends BaseView
  template: require("./templates/optionSelector")

  events:
    "click .remove":"removeOption"
    "click .add":"addOption"

  addOption: ->
    formData = @$("form").serializeArray()
    if _.isArray(@store.filter[@options.key])
      @store.filter[@options.key].push formData[0].value
    else
      @store.filter[@options.key][formData[0].value] = formData[0].value
    Backbone.trigger "filterReset"

  getRenderData: ->
    @options

  removeOption: (e) ->
    option = $(e.target).data("group")
    if _.isArray(@store.filter[@options.key])
      @store.filter[@options.key] = _.reject @store.filter[@options.key], (key) ->
        key is option
    else
      delete @store.filter[@options.key][option]
    Backbone.trigger "filterReset"