BaseView = require "./view"
communityPreparator = require "../libs/communityPreparator"

module.exports = class View extends BaseView
  el: "body"
  template: require("../templates/communityHome")

  events:
    "change #load-file": "fileLoaded"

  init: =>
    @communities = []

  getRenderData: ->
    console.log "GET RENDER DATa", @communities
    {@communities}

  fileLoaded: (e) =>
    fileRef = e.target.files[0]
    reader = new FileReader()

    reader.onload = ((theFile) =>
      (e) =>
        @communities = communityPreparator(e.target.result)
        @render()
    )(fileRef)
    reader.readAsText fileRef
