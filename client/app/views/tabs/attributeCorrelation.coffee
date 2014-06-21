BaseView = require "../view"
forceInt = require "../../libs/forceInt"
BarsLine = require "../../charts/barsLine"
possibleValues = require "../../data/possibleValues"

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

dataMap = (result) ->
  final = []
  for a, b of result.count
    unless a is "false"
      final.push {plus:b, minus:0, year:a}
  final = _.sortBy final, (v) ->
    forceInt(v.year)
  return final

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
    @$('#graph').empty()

    for val in correlationResults
      @$('#graph').append """ <h3>Number of communities matching value #{val.val}</h3> """
      BarsLine
        data:val
        elem:@$('#graph')[0]
        processData: dataMap

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
