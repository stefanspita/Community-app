# the main template changing view, which also holds the left side main menu

BaseView = require "./view"
AttributeCorrelation = require "./tabs/attributeCorrelation"
RandomizationTool = require "./tabs/randomizationTool"
CompareRandom = require "./tabs/compareRandom"
Viewer = require "./tabs/viewer"
UploadsView = require "./tabs/uploads"

module.exports = class View extends BaseView
  template: require("./templates/results")

  # click event for the main menu
  events:
    "click .byCat li": "showTab"

  init: ->
    @initialData = @store.get("initialData") ? {}
    @finalData = @store.get("finalData") ? {}

    # when a bar on a chert is clicked this listener handles changing the template to the table view
    Backbone.on "communitiesFiltered", =>
      @showTab(false, "viewer")

  # set class "active" on the element clicked
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

  # select the right template depending on the active element in the menu
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
          view = new Viewer()
        when "uploads"
          view = new UploadsView()
      @$("#mainTemplate").empty()
      if view
        @$("#mainTemplate").append view.render().$el

  # if not enough data, in the application, just display an error message
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
