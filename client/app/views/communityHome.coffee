BaseView = require "./view"
dataMapping = require "../libs/dataMapping"
communityMapping = require "../libs/communityMapping"
ResultsView = require "./results"

module.exports = class View extends BaseView
  el: "body"
  template: require("./templates/communityHome")

  events:
    "change #initial": "loadFile"
    "change #final": "loadFile"

  afterRender: =>
    resultsView = new ResultsView()
    @$el.find("#resultsTemplate").html resultsView.render().$el
    if @store.get("initialData")
      @$el.find("#initialData").hide()
    if @store.get("finalData")
      @$el.find("#finalData").hide()

  processInitial: =>
    @store.set {initialData: dataMapping(event.target.result, ",", true)}
    @render()

  processFinal: =>
    @store.set {finalData: communityMapping(event.target.result)}
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

