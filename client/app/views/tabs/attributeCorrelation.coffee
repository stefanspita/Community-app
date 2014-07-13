BaseView = require "../view"
possibleValues = require "../../data/possibleValues"
DetailView= require "./correlationDetail"
OptionView = require "../option"
calculateCorrelation = require "../../libs/calculateCorrelation"

module.exports = class View extends BaseView
  template: require("./templates/attributeCorrelation")

  events:
    "click #addOption": "addOption"
    "change select": "updateData"

  init: ->
    @initialData = @store.get("initialData")
    @finalData = @store.get("finalData")
    @optionCount = 0
    @listenTo Backbone, 'filterOption:removed', @updateData

  afterRender: =>
    #@$("#addOption").show()
    @addOption()

  updateData: ->
    formData = @$("form").serializeArray()
    {summary, question} = calculateCorrelation(formData, @initialData, @finalData)
    @$(".question").html question
    @$('.detail').empty()

    for val in summary
      detailView = new DetailView({data:val})
      @$('.detail').append detailView.render().$el

  addOption: ->
    @optionCount += 1
    optionView = new OptionView({name:"option#{@optionCount}", headers:_.keys(possibleValues)})
    @$el.find("form").append optionView.render().$el