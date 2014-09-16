# this is the first view being displayed if all required data is loaded in. It creates a view for each possible answer of the
# question selected by user
# It also has simple filters defined on it to sort the questions in the select box by the community defining probability or
# by the non-random probability
# Other filters are used to add a minimum probability value for the questions displayed in the select box

BaseView = require "../view"
possibleValues = require "../../data/possibleValues"
DetailView= require "./correlationDetail"
QuestionSelect = require "./questionSelect"
correlationHelpers = require "../../libs/correlationHelpers"
request = require('../../libs/ajaxRequest')()

module.exports = class View extends BaseView
  template: require("./templates/attributeCorrelation")

  events:
    "change select": "updateData"
    "click .calculate":"getCommunityAttributes"
    "click .restore":"restoreAttributes"
    "click .sortByRandom":"sortByRandom"
    "click .sortByCorrelation":"sortByCorrelation"
    "change .filters input":"filterQuestions"

  sortByRandom: =>
    @sorter = "maxNonRandomChance"
    @render()

  sortByCorrelation: =>
    @sorter = "total"
    @render()

  filterQuestions: =>
    @correlationFilter = @$("#correlationFilter").val()
    @randomFilter = @$("#randomFilter").val()
    @render()

  init: ->
    @initialData = @store.get("initialData")
    @finalData = @store.get("finalData")
    @listenTo Backbone, 'filterOption:removed', @updateData

  getRenderData: ->
    {@included, @sorter, @correlationFilter, @randomFilter}

  afterRender: =>
    if @correlationFilter
      @applyFilters()
    @addOption()
    @updateData()

  applyFilters: =>
    correlationFilter = parseInt(@correlationFilter)
    randomFilter = parseInt(@randomFilter)
    @included = _.filter @correlationData, (question) =>
      check = true
      if correlationFilter and (question.probability?.total < correlationFilter)
        check = false
      if randomFilter and (question.probability?.maxNonRandomChance < randomFilter)
        check = false
      check

  updateData: ->
    formData = @$("form").serializeArray()
    {summary, question} = correlationHelpers.getFullAttributeCorrelation(formData, @initialData, @finalData)
    @$(".question").html question
    @$('.detail').empty()

    for val in summary
      if @included
        q = _.findWhere @included, {question:(formData[0].value)}
      detailView = new DetailView({data:val, question:formData[0].value, probability:q?.probability})
      @$('.detail').append detailView.render().$el

  addOption: ->
    optionView = new QuestionSelect({name:"option", @included, @sorter})
    @$el.find("form p").prepend optionView.render().$el

  getCommunityAttributes: =>
    $(".loadingLayout").css("display", "block")
    request "getCommunityAttributes", null, null, (err, result) =>
      if err
        console.log err
        alert "An error occurred while fetching the data. Please contact the site administrator."
      else if result?.data?.length
        @correlationData = result.data
        @included = result.data
        @sorter = "total"
        @render()
      $(".loadingLayout").css("display", "none")

  restoreAttributes: =>
    @correlationFilter = false
    @included = false
    @sorter = false
    @render()