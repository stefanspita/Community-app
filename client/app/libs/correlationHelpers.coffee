forceInt = require "./forceInt"
possibleValues = require "../data/possibleValues"
answerTypes = require "../data/answerTypes"

getIndexes = (formData, initialData) ->
  indexes = []
  for option, index in formData
    if option.value
      indexes.push _.indexOf initialData.header, option.value
  indexes

getIndexes2 = (formData, initialData) ->
  indexes = []
  for option, index in formData
    if option
      indexes.push _.indexOf initialData.header, option
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
    correlationResults.push {totalNodes:community.length, attributesSet:forceInt(attributesSet.true), attributeVals}
  correlationResults

getSummary = (results, ind, headers) ->
  h = headers[ind]
  summary = []
  for val in possibleValues[h].options
    r = _.countBy results, (community) ->
      if community.attributesSet > 2
        percentage = Math.floor(forceInt(community.attributeVals["#{ind}"]["#{val}"]) / community.attributesSet * 5) * 20
        if percentage >= 80 then return 80
        return percentage
      else return false
    r = _.omit r, ["false"]
    if _.keys(r).length
      answerType = possibleValues[h].answersType
      answerText = answerTypes[answerType][val]
      summary.push {val, count:r, answerText}
  {summary, question:possibleValues[h].question}

getComparison = (results1, randomResults2, ind, headers) ->
  h = headers[ind]
  truthTest = false
  for val in possibleValues[h].options
    truthTest = false
    r1 = _.countBy results1, (community) ->
      if community.attributesSet > 2
        percentage = Math.floor(forceInt(community.attributeVals["#{ind}"]["#{val}"]) / community.attributesSet * 5)
        if percentage >= 4 then return 4
      return false
    r2 = _.countBy randomResults2, (community) ->
      if community.attributesSet > 2
        ratio = Math.floor(forceInt(community.attributeVals["#{ind}"]["#{val}"]) / community.attributesSet * 5)
        if ratio >= 4 then return 4
      return false
    if (r1["4"] > r2["4"]) and ((r1["4"] - r2["4"]) > 5)
      truthTest = true
      break
  truthTest

module.exports =
  getFullAttributeCorrelation: (formData, initialData, finalData) ->
    indexes = getIndexes(formData, initialData)
    unless indexes.length then return
    correlationResults = getCorrelationPercentages(indexes[0], initialData, finalData)
    return getSummary(correlationResults, indexes[0], initialData.header)

  getComparisonKeys: (keys, initialData, finalData, randomFinalData) ->
    filteredKeys = []
    indexes = getIndexes2(keys, initialData)
    for i in indexes
      correlationResults1 = getCorrelationPercentages(i, initialData, finalData)
      correlationResults2 = getCorrelationPercentages(i, initialData, randomFinalData)
      truthTest = getComparison(correlationResults1, correlationResults2, i, initialData.header)
      if truthTest
        filteredKeys.push initialData.header[i]
    console.log filteredKeys.length, keys.length
    filteredKeys
