forceInt = require "./forceInt"
possibleValues = require "../data/possibleValues"
answerTypes = require "../data/answerTypes"

getIndexes = (formData, initialData) ->
  indexes = []
  for option, index in formData
    if option.value
      indexes.push _.indexOf initialData.header, option.value
  indexes

getCorrelationPercentages = (indexes, initialData, finalData) =>
  correlationResults = []
  for community, index in finalData
    attributesSet = _.countBy community, (node) =>
      if initialData[node]
        for i in indexes
          if initialData[node][i] > -10
            return true
      return false
    attributeVals = {}
    for i in indexes
      attributeVals["#{i}"] = _.countBy community, (node) =>
        if initialData[node]
          return initialData[node][i]
        else return false
    correlationResults.push {totalNodes:community.length, attributesSet:forceInt(attributesSet.true), attributeVals}
  correlationResults

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

module.exports = (formData, initialData, finalData) ->
  indexes = getIndexes(formData, initialData)
  unless indexes.length then return
  correlationResults = getCorrelationPercentages(indexes, initialData, finalData)
  return getSummary(correlationResults, indexes, initialData.header)