tempViews = require '../libs/tempViews'
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

    # We have to ensure a timeout so that parent views are rendered before
    # child views
    # Not sure why underscore defer didnt work here....
    triggerSubViews = =>
      for key, view of @subViews
        do (view) ->
          trigger = ->
            view.trigger("visible")
          setTimeout trigger, 1


    @init.apply this, arguments

    @on "visible", triggerSubViews

  template: ->
    return

  getRenderData: =>
    @model.toJSON() if @model

  className: "main-view"

  render: =>
    @$el.html (@template @getRenderData())
    @renderTempViews()
    @afterRender()
    @setupBindings() if (@bindings and @model)
    this

  afterRender: ->
    return

  setupBindings: ->
    for key, val of @bindings
      @listenTo @model, "change:#{key}", bindingFn(val, @$)


  dispose: ->
    @trigger("remove")
    @undelegateEvents() # Remove dom events
    @off() # Remove this views events
    @model?.off(null, null, this) # Remove model events that have this views context
    @collection?.off(null, null, this) # Remove collection events that have this views context
    if @r # Remove Raphael events
      @r.forEach (el) ->
        el.off()
    if $.fn.select2
      @$('select').select2("destroy")
    view.dispose() for id, view of @subViews
    delete @subViews
    @model = null
    @collection = null
    @options = null
    @remove()
    @scroller?.destroy()
    @scroller = null
    clearTimeout(@timer)
    #console.warn "dispose", @constructor.name, @subViews
    this

  modelOn: (event, callback) ->
    @model.on event, callback, this

  collectionOn: (event, callback) ->
    @collection.on event, callback, this

  detach: =>
    @$el.detach()


  renderTempViews: ->
    view = @
    #console.warn "renderTemp", view.constructor.name
    @$('view').each ->
      elem = $(@)
      id = elem.attr("data-id")
      viewData = tempViews[id]
      SubView = _.require viewData.viewName, "views/#{viewData.viewName}", "BSM/views/#{viewData.viewName}"
      if _.isFunction(SubView)
        view.subViews[id] = subView = new SubView _.extend({}, view.options, viewData.data)
        view.subViewsByType[viewData.viewName] ?= []
        view.subViewsByType[viewData.viewName].push subView
        elem.replaceWith subView.el
        #delete tempViews[id] #memory...

      else
        console.warn "Invalid subview data", viewData