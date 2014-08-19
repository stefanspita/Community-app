BaseView = require "./view"
helpers = require "../libs/dataMappingHelpers"
communityMapping = require "../libs/communityMapping"
ResultsView = require "./results"
request = require('../libs/ajaxRequest')()

module.exports = class View extends BaseView
  el: "body"
  template: require("./templates/communityHome")

  events:
    "change #initial": "loadFile"
    "change #final": "loadFile"

  init: ->
    request "getData/initialData", null, null, (err, result) =>
      if err
        console.log err
        alert "An error occurred while fetching the data. Please contact the administrator to solve th problem."
      else if result?.data?.length
        @store.set {initialData: helpers.dataMapping(result.data)}
        @render()

    request "getData/finalData", null, null, (err, result) =>
      if err
        console.log err
        alert "An error occurred while fetching the data. Please contact the administrator to solve th problem."
      else if result?.data[0]?.finalData
        @store.set {finalData:result.data[0].finalData}
        @render()

  afterRender: =>
    resultsView = new ResultsView()
    @$el.find("#resultsTemplate").html resultsView.render().$el
    if @store.get("initialData")
      @$el.find("#initialData").hide()
    if @store.get("finalData")
      @$el.find("#finalData").hide()

  processInitial: =>
    arr = helpers.dbDataMapping(event.target.result, ",", true)
    initialData = helpers.dataMapping(arr)
    @store.set {initialData}
    request "saveData/initialData", arr, "POST", (err) =>
      if err
        console.log err
        alert "An error occurred while saving the data. Please contact the administrator to solve the problem."
      else console.log "DONE"
    @render()

  processFinal: =>
    obj = {finalData: communityMapping(event.target.result)}
    @store.set obj
    request "saveData/finalData", obj, "POST", (err) =>
      if err
        console.log err
        alert "An error occurred while saving the data. Please contact the administrator to solve the problem."
      else console.log "DONE"
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

