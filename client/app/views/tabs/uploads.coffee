BaseView = require "../view"
helpers = require "../../libs/dataMappingHelpers"
communityMapping = require "../../libs/communityMapping"
request = require('../../libs/ajaxRequest')()

module.exports = class View extends BaseView
  template: require("./templates/uploads")

  events:
    "change #initial": "loadFile"
    "change #final": "loadFile"

  processInitial: =>
    arr = helpers.dbDataMapping(event.target.result, ",", true)
    initialData = helpers.dataMapping(arr)
    @store.set {initialData}
    request "saveData/initialData", arr, "POST", (err) =>
      if err
        console.log err
        alert "An error occurred while saving the data. Please contact the administrator to solve the problem."
      else console.log("DONE")

  processFinal: =>
    obj = {finalData: communityMapping(event.target.result)}
    @store.set obj
    request "saveData/finalData", obj, "POST", (err) =>
      if err
        console.log err
        alert "An error occurred while saving the data. Please contact the administrator to solve the problem."
      else console.log("DONE")

  loadFile: (e) =>
    @$(".green").remove()
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