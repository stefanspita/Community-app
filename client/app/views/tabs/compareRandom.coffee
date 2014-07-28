BaseView = require "../view"
possibleValues = require "../../data/possibleValues"
DoubleDetailView= require "./comparisonDetail"
OptionView = require "../option"
correlationHelpers = require "../../libs/correlationHelpers"

module.exports = class View extends BaseView
  template: require("./templates/compareRandom")

  events:
    "click #addOption": "addOption"
    "change select": "updateData"

  init: ->
    @initialData = @store.get("initialData")
    @finalData = @store.get("finalData")
    @optionCount = 0
    @filteredKeys = []
    @listenTo Backbone, 'filterOption:removed', @updateData

  getRenderData: ->
    unless @store.get("randomCommunities")
      error = "Please use the randomization tool to generate a random community first"
    unless @filteredKeys.length
      noData = true
    {error, noData}

  afterRender: =>
    @addOption()
    if @store.get("randomCommunities")
      @updateData()

  calculate: =>
    @filteredKeys = correlationHelpers.getComparisonKeys(_.keys(possibleValues), @initialData, @finalData, @store.get("randomCommunities"))
    @render()

  updateData: ->
    formData = @$("form").serializeArray()
    realData = correlationHelpers.getFullAttributeCorrelation(formData, @initialData, @finalData)
    randomData = correlationHelpers.getFullAttributeCorrelation(formData, @initialData, @store.get("randomCommunities"))
    @$(".question").html realData.question
    @$('.detail').empty()

    for val, index in realData.summary
      detailView = new DoubleDetailView({realData:val, randomData:randomData.summary[index], question:formData[0].value})
      @$('.detail').append detailView.render().$el

  addOption: ->
    @optionCount += 1
    optionView = new OptionView({name:"option#{@optionCount}", headers:_.keys(possibleValues)})
    @$el.find("form").append optionView.render().$el
