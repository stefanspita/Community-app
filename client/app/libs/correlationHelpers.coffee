forceInt = require "./forceInt"
possibleValues = require "../data/possibleValues"
answerTypes = require "../data/answerTypes"

getIndexes = (formData, initialData) ->
  indexes = []
  for option, index in formData
    if option.value
      indexes.push _.indexOf initialData.header, option.value
  indexes

getCorrelationPercentages = (ind, initialData, finalData) =>
  correlationResults = []
  for community, index in finalData
    attributesSet = _.countBy community, (node) =>
      if initialData[node]
        if initialData[node][ind] > -10
          return true
      return false
    attributeVals = {}
    attributeVals["#{ind}"] = _.countBy community, (node) =>
      if initialData[node]
        return initialData[node][ind]
      else return false
    correlationResults.push {totalNodes:community.length, attributesSet:forceInt(attributesSet.true), attributeVals, index}
  correlationResults

getSummary = (results, ind, headers) ->
  h = headers[ind]
  summary = []
  for val in possibleValues[h].options
    r = _.groupBy results, (community) ->
      if community.attributesSet > 2
        percentage = Math.floor(forceInt(community.attributeVals["#{ind}"]["#{val}"]) / community.attributesSet * 5) * 20
        if percentage >= 80 then return 80
        return percentage
      else return false
    r = _.omit r, ["false"]
    if _.keys(r).length
      answerType = possibleValues[h].answersType
      answerText = answerTypes[answerType][val]
      count = {}
      for key, comms of r
        communities = _.map comms, (comm) ->
          comm.index
        count[key] = {size:comms.length, communities}
      summary.push {val, count, answerText}
  {summary, question:possibleValues[h].question}

module.exports =
  getFullAttributeCorrelation: (formData, initialData, finalData) ->
    indexes = getIndexes(formData, initialData)
    unless indexes.length then return
    correlationResults = getCorrelationPercentages(indexes[0], initialData, finalData)
    return getSummary(correlationResults, indexes[0], initialData.header)

