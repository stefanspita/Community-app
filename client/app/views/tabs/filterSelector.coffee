# filter views to show all the set filters and give the user the ability to add new ones or remove existing ones
# used by the question filter only

BaseView = require "../view"
possibleValues = require "../../data/possibleValues"
answerTypes = require "../../data/answerTypes"
select = require "./templates/select"
QuestionSelect = require "./questionSelect"

module.exports = class View extends BaseView
  template: require("./templates/filterSelector")

  events:
    "click .remove":"removeOption"
    "click .add":"addOption"
    "change [name='key']":"updateAnswers"

  updateAnswers: (event, key) ->
    key = @$("[name='key']").val()
    answersType = possibleValues[key].answersType
    options = _.map possibleValues[key].options, (answer) ->
      {label:answerTypes[answersType][answer], value:answer}
    @$(".valSelect").html select({options, name:"val"})

  addOption: ->
    formData = @$("form").serializeArray()
    key = _.findWhere(formData, {name:"key"}).value
    value = _.findWhere(formData, {name:"val"}).value
    @store.filter[@options.key][key] = value
    Backbone.trigger "filterReset"

  afterRender: =>
    questionSelect = new QuestionSelect({name:"key"})
    @$(".questionSelect").html questionSelect.render().$el
    @updateAnswers()

  getRenderData: ->
    data = _.map @store.filter.filters, (answer, question) ->
      answersType = possibleValues[question].answersType
      {question, answer:answerTypes[answersType][answer], title:possibleValues[question].question}
    _.extend @options, {data}

  removeOption: (e) ->
    option = $(e.target).data("key")
    if _.isArray(@store.filter[@options.key])
      @store.filter[@options.key] = _.reject @store.filter[@options.key], (key) ->
        key is option
    else
      delete @store.filter[@options.key][option]
    Backbone.trigger "filterReset"