BaseView = require "./view"
OptionView = require "./option"
AttributeCorrelation = require "./tabs/attributeCorrelation"

module.exports = class View extends BaseView
  template: require("../templates/results")

  events:
    "click #addOption": "addOption"
    "change select": "updateData"
    "click .byCat li": "showTab"

  init: ->
    @initialData = @options.initialData
    @finalData = @options.finalData
    @optionCount = 0
    @listenTo Backbone, 'filterOption:removed', @updateData

  showTab: (e) =>
    $elem = $(e.target)
    @$('.byCat li').removeClass "active"
    $elem.addClass("active")
    @updateData()

  getRenderData: ->
    {error:@validate()}

  afterRender: =>
    if @validate() is ""
      @$("addOption").show()
      @addOption()

  updateData: =>
    formData = @$("form").serializeArray()
    template = @$('.byCat li.active').data("template")
    if template and formData
      @$("#mainTemplate").empty()
      tabView = @templateSwitch(template, formData)
      @$("#mainTemplate").append tabView.render().$el

  templateSwitch: (template, formData) ->
    switch template
      when "attributeCorrelation"
        view = new AttributeCorrelation({@finalData, @initialData, formData})
    return view

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
