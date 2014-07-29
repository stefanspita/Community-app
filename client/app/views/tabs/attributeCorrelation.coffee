BaseView = require "../view"
possibleValues = require "../../data/possibleValues"
DetailView= require "./correlationDetail"
QuestionSelect = require "./questionSelect"
correlationHelpers = require "../../libs/correlationHelpers"

module.exports = class View extends BaseView
  template: require("./templates/attributeCorrelation")

  events:
    "change select": "updateData"

  init: ->
    @initialData = @store.get("initialData")
    @finalData = @store.get("finalData")
    @listenTo Backbone, 'filterOption:removed', @updateData

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
    optionView = new QuestionSelect({name:"option"})
    @$el.find("form").append optionView.render().$el