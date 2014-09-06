fs = require("fs")
fluent = require("fluent-async")
_ = require("underscore")
possibleValues = require("./client/app/data/possibleValues")

getInitialData = (db, callback) ->
  collection = db.collection("initialData")
  collection.find().toArray callback

getCommunityData = (db, callback) ->
  collection = db.collection("finalData")
  collection.find().toArray callback

dataMapping = (personList) ->
  people = {}
  for person in personList
    _.extend people, person
  people = _.omit people, "_id"
  people

calculateCorrelation = (data, communities) ->
  communities = communities[0].finalData
  questionData = []
  for question, opts of possibleValues
    sum = 0
    if opts.options
      questionIndex = _.indexOf data.header, question
      total = _.countBy data, (val) ->
        if parseInt(val[questionIndex]) > -10
          return val[questionIndex]
        else return false
      total = _.omit total, "false"
      total.sum = _.reduce total, (memo, num) ->
        memo + num
      , 0
      probability = checkCommunity(communities, data, questionIndex, opts.options, total)
      questionData.push {probability, question}
  questionData

checkCommunity = (communities, data, ind, answers, total) ->
  probability = {total:0, maxNonRandomChance:0, nonRandomChance:{}, totalProbability:{}}
  count = {}
  for answer in answers
    probability.totalProbability[answer] = total[answer] / total.sum
  for community in communities
    responded = _.countBy community, (node) =>
      if data[node]
        if parseInt(data[node][ind]) > -10
          return true
      return false
    if (not responded.true) or (responded.true < 3) then continue
    attributeVals = _.countBy community, (node) =>
      if data[node]
        return data[node][ind]
      else return false
    for answer in answers
      count[answer] ?= 0
      probability[answer] ?= 0
      probability.nonRandomChance[answer] ?= 0
      commFraction = attributeVals[answer] / responded.true
      if commFraction >= Math.max(probability.totalProbability[answer], 0.8)
        probability[answer] += commFraction
        count[answer] += 1
        probability.nonRandomChance[answer] += (Math.pow(responded.true / community.length, 3 / responded.true))

  for answer in answers
    probability.totalProbability[answer] *= 100
    unless count[answer] is 0
      probability.nonRandomChance[answer] = probability.nonRandomChance[answer] / count[answer] * 100
      decrease = Math.min(10, count[answer]) / 10
      probability[answer] = ((probability[answer] / count[answer]) * 100 - probability.totalProbability[answer]) * decrease
      probability.total = Math.max(probability[answer], probability.total)
      if probability[answer] is probability.total
        probability.maxNonRandomChance = probability.nonRandomChance[answer]
  probability

module.exports = (db, callback) ->
  fluent.create(db: db)
  .strict()
  .async({getInitialData}, "db")
  .async({getCommunityData}, "db")
  .sync({dataMapping}, "getInitialData")
  .sync({calculateCorrelation}, "dataMapping", "getCommunityData")
  .run(callback, "calculateCorrelation")
