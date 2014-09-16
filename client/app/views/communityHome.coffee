# the first view that is being run

BaseView = require "./view"
helpers = require "../libs/dataMappingHelpers"
communityMapping = require "../libs/communityMapping"
ResultsView = require "./viewChanger"
request = require('../libs/ajaxRequest')()

module.exports = class View extends BaseView
  el: "div.main-app"
  template: require("./templates/communityHome")

  events:
    "change #initial": "loadFile"
    "change #final": "loadFile"

  init: ->
    # show loading overlay to block the user from using it
    $(".loadingLayout").css("display", "block")

    # request questionnaire data from the server. if not found in the database, the user will be expected to upload a file in
    request "getData/initialData", null, null, (err, result) =>
      if err
        console.log err
        alert "An error occurred while fetching the data. Please contact the administrator to solve th problem."
      else if result?.data?.length
        @store.set {initialData: helpers.dataMapping(result.data)}
        @render()

      # this is always the longer request, because of the size of data, so only hide the loading overlay when this request is finished
      $(".loadingLayout").css("display", "none")

    # request communities list from the server. if not found in the database, the user will be expected to upload a file in
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

    # hide the file upload forms if the data was successfully fetched from the database
    if @store.get("initialData")
      @$el.find("#initialData").hide()
    if @store.get("finalData")
      @$el.find("#finalData").hide()

  processInitial: =>
    arr = helpers.dbDataMapping(event.target.result, ",", true)
    initialData = helpers.dataMapping(arr)
    @store.set {initialData}

    # when successfully uploaded questionnaire data file, send it to the server to be saved in the database
    request "saveData/initialData", arr, "POST", (err) =>
      if err
        console.log err
        alert "An error occurred while saving the data. Please contact the administrator to solve the problem."
      else console.log "DONE"
    @render()

  processFinal: =>
    obj = {finalData: communityMapping(event.target.result)}
    @store.set obj

    # when successfully uploaded communities list file, send it to the server to be saved in the database
    request "saveData/finalData", obj, "POST", (err) =>
      if err
        console.log err
        alert "An error occurred while saving the data. Please contact the administrator to solve the problem."
      else console.log "DONE"
    @render()

  # generic file reader
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

