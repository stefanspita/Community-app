BaseView = require "./view"
dataMapping = require "../libs/dataMapping"
communityMapping = require "../libs/communityMapping"
ResultsView = require "./results"

module.exports = class View extends BaseView
  el: "body"
  template: require("../templates/communityHome")

  events:
    "change #initial": "loadFile"
    "change #final": "loadFile"

  init: =>
    @initialData = {}
    @finalData = []

  afterRender: =>
    resultsView = new ResultsView({@initialData, @finalData})
    @$el.find("#resultsTemplate").append resultsView.render().$el

  processInitial: =>
    @initialData = dataMapping(event.target.result, ",", true)
    @render()

  processFinal: =>
    @finalData = communityMapping(event.target.result)
    @render()

  loadFile: (e) =>
    inputId = $(e.target).attr("id")
    fileRef = e.target.files[0]
    reader = new FileReader()
    reader.onload = ((theFile) =>
      (event) =>
        if inputId is "initial"
          @processInitial()
        else
          @processFinal()
    )(fileRef)
    reader.readAsText fileRef

