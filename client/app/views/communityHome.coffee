BaseView = require "./view"
lineReturn = require "../libs/lineReturn"
ResultsView = require "./results"

module.exports = class View extends BaseView
  el: "body"
  template: require("../templates/communityHome")

  events:
    "change #initial": "loadFile"
    "change #final": "loadFile"

  init: =>
    @initialData = []
    @finalData = []

  afterRender: =>
    resultsView = new ResultsView({@initialData, @finalData})
    @$el.find("#resultsTemplate").append resultsView.render().$el

  processInitial: =>
    @initialData = lineReturn(event.target.result)
    @render()

  processFinal: =>
    @finalData = lineReturn(event.target.result)
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

