BaseView = require "../view"
possibleValues = require "../../data/possibleValues"
DetailView= require "./correlationDetail"
OptionView = require "../option"
correlationHelpers = require "../../libs/correlationHelpers"

module.exports = class View extends BaseView
  template: require("./templates/compareRandom")

  events:
    "click #addOption": "addOption"
    "change select": "updateData"
    "click #calculate":"calculate"

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
    #@$("#addOption").show()
    @addOption()

  calculate: =>
    @filteredKeys = correlationHelpers.getComparisonKeys(_.keys(possibleValues), @initialData, @finalData, @store.get("randomCommunities"))
    @render()

  updateData: ->
    formData = @$("form").serializeArray()
    {summary, question} = correlationHelpers.getFullAttributeCorrelation(formData, @initialData, @finalData)
    @$(".question").html question
    @$('.detail').empty()

    for val in summary
      detailView = new DetailView({data:val})
      @$('.detail').append detailView.render().$el

  addOption: ->
    if @filteredKeys.length
      @optionCount += 1
      optionView = new OptionView({name:"option#{@optionCount}", headers:@filteredKeys})
      @$el.find("form").append optionView.render().$el
      @$el.find("#calculate").addClass("hidden")
