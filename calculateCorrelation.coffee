fs = require("fs")
fluent = require("fluent-async")
_ = require("underscore")
possibleValues = require("./client/app/data/possibleValues")

# fetch questionnaire data from the database
getInitialData = (db, callback) ->
  collection = db.collection("initialData")
  collection.find().toArray callback

# fetch communities list from the database
getCommunityData = (db, callback) ->
  collection = db.collection("finalData")
  collection.find().toArray callback

# remove the "_id" attribute added by the database on each of the database entries and return the questionnaire data
dataMapping = (personList) ->
  people = {}
  for person in personList
    _.extend people, person
  people = _.omit people, "_id"
  people

# loops through every question and answer in the data set and gets the probability of each being community defining and
# outputs them in an array named "questionData
calculateCorrelation = (data, communities) ->
  communities = communities[0].finalData
  questionData = []
  for question, opts of possibleValues
    if opts.options
      questionIndex = _.indexOf data.header, question

      # counts how many times each possible answer was used to answer a question
      total = _.countBy data, (val) ->
        if parseInt(val[questionIndex]) >= 0
          return val[questionIndex]
        else return false
      total = _.omit total, "false"

      # counts how many ALSPAC people actually answered a question
      total.sum = _.reduce total, (memo, num) ->
        memo + num
      , 0

      # for each question, the "checkCommunity" function is being run and its results pushed to the return array
      probability = checkCommunity(communities, data, questionIndex, opts.options, total)
      questionData.push {probability, question}
  questionData


# this function uses the possible answers for a question and checks every community against them to calculate
# the probability of them being community defining and the non-random probability
checkCommunity = (communities, data, ind, answers, total) ->

  #initialize the return array
  probability = {total:0, maxNonRandomChance:0, nonRandomChance:{}, totalProbability:{}, count: {}}

  # calculate probability of each answer being used in the whole data set
  for answer in answers
    probability.totalProbability[answer] = total[answer] / total.sum

  for community in communities
    # counts all valid answers in a community. If less than 3 valid answers, the community is ignored for the calculation
    responded = _.countBy community, (node) =>
      if data[node]
        if parseInt(data[node][ind]) >= 0
          return true
      return false
    if (not responded.true) or (responded.true < 3) then continue

    # counts all actual answers, including N/A, but only rejecting -10 (questionnaire not returned)
    respondedAll = _.countBy community, (node) =>
      if data[node]
        if parseInt(data[node][ind]) > -10
          return true
      return false

    # counts the number of uses for each answer for a community
    attributeVals = _.countBy community, (node) =>
      if data[node]
        return data[node][ind]
      else return false

    for answer in answers
      probability.count[answer] ?= 0
      probability[answer] ?= 0
      probability.nonRandomChance[answer] ?= 0
      commFraction = attributeVals[answer] / responded.true

      # if the probability of an answer to be used by a community is greater than the maximum of 80% and the whole data set average,
      # it increases the probability of the answer to be community defining
      if commFraction >= Math.max(probability.totalProbability[answer], 0.8)
        probability[answer] += commFraction
        probability.count[answer] += 1
        probability.nonRandomChance[answer] += (Math.pow(respondedAll.true / community.length, 3 / respondedAll.true))

  # the initial probabilities obtained above are averaged per community
  for answer in answers
    probability.totalProbability[answer] *= 100
    unless probability.count[answer] is 0
      probability.nonRandomChance[answer] = probability.nonRandomChance[answer] / probability.count[answer] * 100

      # if less than 5 communities found to be relevant, the probability of the answer being community defining rapidly decreases
      decrease = Math.min(5, probability.count[answer]) / 5

      probability[answer] = ((probability[answer] / probability.count[answer]) * 100 - probability.totalProbability[answer]) * decrease

      # the maximum probabilities for each answer is set on the question, so the question set can be sorted according to their best answer
      probability.total = Math.max(probability[answer], probability.total)
      if probability[answer] is probability.total
        probability.maxNonRandomChance = probability.nonRandomChance[answer]
  probability

# the public part of this file is a function which creates an asynchronous queue of functions being run and
# returns what the "calculateCorrelation" function returns
module.exports = (db, callback) ->
  fluent.create(db: db)
  .strict()
  .async({getInitialData}, "db")
  .async({getCommunityData}, "db")
  .sync({dataMapping}, "getInitialData")
  .sync({calculateCorrelation}, "dataMapping", "getCommunityData")
  .run(callback, "calculateCorrelation")
