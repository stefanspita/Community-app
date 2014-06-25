$ = jQuery

bindingFn = (selector, $) ->
  (model, val) ->
    $(selector).each ->
      $elem = $(@)
      if @tagName in ["INPUT", "SELECT"]
        $elem.val(val)
      else
        $elem.text(val)

# Base class for all views.
module.exports = class View extends Backbone.View
  init: ->

  initialize: =>
    @subViews = {}
    @subViewsByType = {}
    @init.apply this, arguments

  template: ->
    return

  getRenderData: =>
    @model.toJSON() if @model

  className: "main-view"

  render: =>
    @$el.html (@template @getRenderData())
    @afterRender()
    @setupBindings() if (@bindings and @model)
    this

  afterRender: ->
    return

  setupBindings: ->
    for key, val of @bindings
      @listenTo @model, "change:#{key}", bindingFn(val, @$)
