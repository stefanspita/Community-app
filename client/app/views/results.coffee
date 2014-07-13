BaseView = require "./view"
AttributeCorrelation = require "./tabs/attributeCorrelation"
RandomizationTool = require "./tabs/randomizationTool"
CompareRandom = require "./tabs/compareRandom"

module.exports = class View extends BaseView
  template: require("./templates/results")

  events:
    "click .byCat li": "showTab"

  init: ->
    @initialData = @store.get("initialData") ? {}
    @finalData = @store.get("finalData") ? {}

  showTab: (e) =>
    $elem = $(e.target)
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
          formData = @$("form").serializeArray()
          view = new AttributeCorrelation({formData})
        when "randomizationTool"
          view = new RandomizationTool()
        when "compareRandom"
          view = new CompareRandom()
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
