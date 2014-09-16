# this file calculates the distribution of answers for a question in the whole set of communities

forceInt = require "./forceInt"
possibleValues = require "../data/possibleValues"
answerTypes = require "../data/answerTypes"

# get the index of the question codes passed in as input. this index will be used to get the question's answers from the whole questionnaire data
getIndexes = (formData, initialData) ->
  indexes = []
  for option in formData
    if option.value
      indexes.push _.indexOf initialData.header, option.value
  indexes

# for each community, the possible answer uses and the total number of responses are counted (answer >= 0)
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

# map of each answer in each community to 5 ranges of values, defined by the lower limit (0, 20, 40, 60, 80)
# only include communities having more than 2 responses for the question
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

# if the answers for the question are actual numbers, 5 ranges of answers are created between 0 and the maximum answer defined
# in the "data/possibleValues.coffee" file.
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


###
  Inputs:
  - formData: the form data contains an array with the user selected question code in it
  - initialData: questionnaire data
  - finalData: communities list

  Outputs:
  - the distribution of answers for a question in the whole set of communities
###
module.exports =
  getFullAttributeCorrelation: (formData, initialData, finalData) ->
    indexes = getIndexes(formData, initialData)
    unless indexes.length then return
    correlationResults = getCorrelationPercentages(indexes[0], initialData, finalData, initialData.header[indexes[0]])
    return getSummary(correlationResults, indexes[0], initialData.header[indexes[0]])

