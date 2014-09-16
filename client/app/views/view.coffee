# base view from which every other view in the application inherits

app = require "application"

# Base class for all views.
module.exports = class View extends Backbone.View
  init: ->

  initialize: =>
    # the store model is made available in every view
    @store = app.store

    @subViews = {}
    @subViewsByType = {}
    @init.apply this, arguments

  template: ->
    return

  getRenderData: =>
    @model.toJSON() if @model

  className: "main-view"

  render: =>
    # set the template of the view and send the getRenderData outputs to it, for display
    @$el.html (@template @getRenderData())

    # call this function when the template is fully loaded
    @afterRender()

    this

  afterRender: ->
    return

