BaseView = require "../view"
forceInt = require "../../libs/forceInt"
possibleValues = require "../../data/possibleValues"
answerTypes = require "../../data/answerTypes"
DetailView= require "./correlationDetail"
OptionView = require "../option"

getSummary = (results, indexes, headers) ->
  i = indexes[0]
  h = headers[i]
  summary = []
  for val in possibleValues[h].options
    r = _.countBy results, (community) ->
      if community.attributesSet > 2
        percentage = Math.floor(forceInt(community.attributeVals["#{i}"]["#{val}"]) / community.attributesSet * 5) * 20
        if percentage > 80 then return 80
        return percentage
      else return false
    r = _.omit r, ["false"]
    if _.keys(r).length
      answerType = possibleValues[h].answersType
      answerText = answerTypes[answerType][val]
      summary.push {val, count:r, answerText}
  {summary, question:possibleValues[h].question}

module.exports = class View extends BaseView
  template: require("../../templates/tabs/attributeCorrelation")

  events:
    "click #addOption": "addOption"
    "change select": "updateData"

  init: ->
    @initialData = @store.get("initialData")
    @finalData = @store.get("finalData")
    @optionCount = 0
    @listenTo Backbone, 'filterOption:removed', @updateData

  afterRender: =>
    #@updateData()
    #@$("#addOption").show()
    @addOption()

  updateData: ->
    @formData = @$("form").serializeArray()
    indexes = @getIndexes(@formData)
    unless indexes.length then return
    correlationResults = @getCorrelationPercentages(indexes)
    {summary, question} = getSummary(correlationResults, indexes, @initialData.header)
    @$(".question").html question
    @$('.detail').empty()

    for val in summary
      detailView = new DetailView({data:val})
      @$('.detail').append detailView.render().$el

  getCorrelationPercentages: (indexes) =>
    correlationResults = []
    for community, index in @finalData
      attributesSet = _.countBy community, (node) =>
        if @initialData[node]
          for i in indexes
            if @initialData[node][i] > -10
              return true
        return false
      attributeVals = {}
      for i in indexes
        attributeVals["#{i}"] = _.countBy community, (node) =>
          if @initialData[node]
            return @initialData[node][i]
          else return false
      correlationResults.push {totalNodes:community.length, attributesSet:forceInt(attributesSet.true), attributeVals}
    correlationResults

  getIndexes: (data) ->
    indexes = []
    for option, index in data
      if option.value
        indexes.push _.indexOf @initialData.header, option.value
    indexes

  addOption: ->
    @optionCount += 1
    optionView = new OptionView({name:"option#{@optionCount}", headers:_.keys(possibleValues)})
    @$el.find("form").append optionView.render().$el