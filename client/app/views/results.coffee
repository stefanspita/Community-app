BaseView = require "./view"
AttributeCorrelation = require "./tabs/attributeCorrelation"
RandomizationTool = require "./tabs/randomizationTool"
CompareRandom = require "./tabs/compareRandom"
Viewer = require "./tabs/viewer"

module.exports = class View extends BaseView
  template: require("./templates/results")

  events:
    "click .byCat li": "showTab"

  init: ->
    @initialData = @store.get("initialData") ? {}
    @finalData = @store.get("finalData") ? {}
    Backbone.on "communitiesFiltered", (@communities) =>
      @showTab(false, "viewer")

  showTab: (e, viewName) =>
    if e
      $elem = $(e.target)
    else $elem = @$("[data-template='#{viewName}']")
    @$('.byCat li').removeClass "active"
    $elem.addClass("active")
    @templateSwitch()

  getRenderData: ->
    {error:@validate()}

  afterRender: ->
    @templateSwitch()

  templateSwitch: ->
    if @validate() is ""
      template = @$('.byCat li.active').data("template")
      switch template
        when "attributeCorrelation"
          view = new AttributeCorrelation()
        when "randomizationTool"
          view = new RandomizationTool()
        when "compareRandom"
          view = new CompareRandom()
        when "viewer"
          view = new Viewer({@communities})
      @$("#mainTemplate").empty()
      if view
        @$("#mainTemplate").append view.render().$el

  validate: ->
    error = ""
    initialDataLength = _.keys(@initialData).length
    unless initialDataLength or @finalData.length
      error = "Please upload both the input data and the resulting data of the community detection algorithm."
    else unless initialDataLength
      error = "Please upload the input data file used by the community detection algorithm."
    else unless @finalData.length
      error = "Please upload the outputted communities file before continuing."
    error
