BaseView = require "./view"
OptionView = require "./option"

module.exports = class View extends BaseView
  template: require("../templates/results")

  events:
    "click #addOption": "addOption"
    "change select": "updateData"

  init: ->
    @initialData = @options.initialData
    @finalData = @options.finalData
    @optionCount = 0
    @listenTo Backbone, 'filterOption:removed', @updateData

  getRenderData: ->
    {error:@validate()}

  afterRender: ->
    if @initialData.header
      @$("addOption").show()
      @addOption()
    else
      @$("#addOption").hide()

  updateData: ->
    data = @$("form").serializeObject()
    console.log data

  validate: ->
    error = ""
    initialDataLength = _.keys(@initialData).length
    unless initialDataLength or @finalData.length
      error = "Please upload both the input data and the resulting data of the community detection algorithm."
    else unless initialDataLength
      error = "Please upload the input data file used by the community detection algorithm."
    else unless @finalData.length
      error = "Please upload the outputted communities file before continuing."
    error

  addOption: ->
    @optionCount += 1
    optionView = new OptionView({name:"option#{@optionCount}", headers:@initialData.header})
    @$el.find("form").append optionView.render().$el
