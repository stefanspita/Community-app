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

  init: ->
    @initialData = @store.get("initialData")
    @finalData = @store.get("finalData")
    @listenTo Backbone, 'filterOption:removed', @updateData

  getRenderData: ->
    {@included}

  afterRender: =>
    @addOption()
    @updateData()

  updateData: ->
    formData = @$("form").serializeArray()
    {summary, question} = correlationHelpers.getFullAttributeCorrelation(formData, @initialData, @finalData)
    @$(".question").html question
    @$('.detail').empty()

    for val in summary
      detailView = new DetailView({data:val, question:formData[0].value})
      @$('.detail').append detailView.render().$el

  addOption: ->
    optionView = new QuestionSelect({name:"option", included:@included})
    @$el.find("form").append optionView.render().$el

  getCommunityAttributes: =>
    request "getCommunityAttributes", null, null, (err, result) =>
      if err
        console.log err
        alert "An error occurred while fetching the data. Please contact the site administrator."
      else if result?.data?.length
        @included = result.data
        @render()

  restoreAttributes: =>
    @included = false
    @render()