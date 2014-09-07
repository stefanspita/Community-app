forceInt = require "./forceInt"
possibleValues = require "../data/possibleValues"
answerTypes = require "../data/answerTypes"

getIndexes = (formData, initialData) ->
  indexes = []
  for option in formData
    if option.value
      indexes.push _.indexOf initialData.header, option.value
  indexes

getCorrelationPercentages = (ind, initialData, finalData, h) =>
  correlationResults = []
  if possibleValues[h].max then step = possibleValues[h].max / 5
  for community, index in finalData
    attributesSet = _.countBy community, (node) =>
      if initialData[node]
        if parseInt(initialData[node][ind]) >= 0
          return true
      return false
    attributeVals = {}
    attributeVals["#{ind}"] = _.countBy community, (node) =>
      if initialData[node]
        unless step
          return initialData[node][ind]
        else
          if (initialData[node][ind] < 0) or (initialData[node][ind] > possibleValues[h].max) then return false
          return Math.ceil(initialData[node][ind] / step) * step
      else return false
    correlationResults.push {totalNodes:community.length, attributesSet:forceInt(attributesSet.true), attributeVals, index}
  correlationResults

getSummary = (results, ind, h) ->
  summary = []
  if possibleValues[h].options
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
  else if possibleValues[h].max
    summary = getRangeSummary(results, ind, h)
  {summary, question:possibleValues[h].question}

getRangeSummary = (results, ind, h) ->
  step = possibleValues[h].max / 5
  summary = []
  for i in [1..5]
    val = step * i
    r = _.groupBy results, (community) ->
      if community.attributesSet > 2
        percentage = Math.floor(forceInt(community.attributeVals["#{ind}"]["#{val}"]) / community.attributesSet * 5) * 20
        if percentage >= 80 then return 80
        return percentage
      else return false
    r = _.omit r, ["false"]
    if _.keys(r).length
      count = {}
      for key, comms of r
        communities = _.map comms, (comm) ->
          comm.index
        count[key] = {size:comms.length, communities}
      lower = val - step + 1
      if Math.floor(lower) is Math.floor(val)
        answerText = Math.floor(val)
      else answerText = "#{Math.floor(lower)} - #{Math.floor(val)}"
      summary.push {val, count, answerText}
  summary


module.exports =
  getFullAttributeCorrelation: (formData, initialData, finalData) ->
    indexes = getIndexes(formData, initialData)
    unless indexes.length then return
    correlationResults = getCorrelationPercentages(indexes[0], initialData, finalData, initialData.header[indexes[0]])
    return getSummary(correlationResults, indexes[0], initialData.header[indexes[0]])

