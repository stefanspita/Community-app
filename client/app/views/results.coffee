BaseView = require "./view"
AttributeCorrelation = require "./tabs/attributeCorrelation"
RandomizationTool = require "./tabs/randomizationTool"

module.exports = class View extends BaseView
  template: require("../templates/results")

  events:
    "click .byCat li": "showTab"

  init: ->
    @initialData = @options.initialData
    @finalData = @options.finalData

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
          view = new AttributeCorrelation({@finalData, @initialData, formData})
        when "randomizationTool"
          view = new RandomizationTool({@finalData})
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
