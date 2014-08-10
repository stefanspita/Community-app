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
  probability = {total:0}
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
      commFraction = attributeVals[answer] / responded.true
      totalFraction = total[answer] / total.sum + 0.1
      if commFraction >= Math.max(totalFraction, 0.8)
        probability[answer] ?= 0
        probability[answer] += commFraction - totalFraction
        probability.total += commFraction - totalFraction
  probability

module.exports = (db, callback) ->
  fluent.create(db: db)
  .strict()
  .async({getInitialData}, "db")
  .async({getCommunityData}, "db")
  .sync({dataMapping}, "getInitialData")
  .sync({calculateCorrelation}, "dataMapping", "getCommunityData")
  .run(callback, "calculateCorrelation")
