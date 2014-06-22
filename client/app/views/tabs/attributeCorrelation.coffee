BaseView = require "../view"
forceInt = require "../../libs/forceInt"
BarsLine = require "../../charts/barsLine"
possibleValues = require "../../data/possibleValues"
DetailView= require "./correlationDetail"

getSummary = (results, indexes, headers) ->
  i = indexes[0]
  h = headers[i]
  summary = []
  for val in possibleValues[h]
    r = _.countBy results, (community) ->
      if community.attributesSet > 2
        return (forceInt(community.attributeVals["#{i}"]["#{val}"]) / community.attributesSet * 100).toFixed(2)
      else return false
    summary.push {val, count:r}
  return summary

module.exports = class View extends BaseView
  template: require("../../templates/tabs/attributeCorrelation")

  init: ->
    @initialData = @options.initialData
    @finalData = @options.finalData
    @formData = @options.formData

  afterRender: =>
    @updateData()

  updateData: ->
    indexes = @getIndexes(@formData)
    correlationResults = @getCorrelationPercentages(indexes)
    correlationResults = getSummary(correlationResults, indexes, @initialData.header)
    @$('#detail').empty()

    for val in correlationResults
      detailView = new DetailView({data:val, title:"Number of communities matching value #{val.val}"})
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
