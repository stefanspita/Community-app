# this view is used to generate a random set of communities and set it on the store model

BaseView = require "../view"

module.exports = class View extends BaseView
  template: require("./templates/randomizationTool")

  events:
    "click a.randomize":"randomize"

  init: ->
    @finalData = @store.get("finalData")
    @randomCommunities = @store.get("randomCommunities")

  getRenderData: ->
    { noOfComms:@randomCommunities?.length }

  randomize: =>
    @nodesList = _.unique(_.flatten(@finalData))
    randomOrder = _.sample(@nodesList, @nodesList.length)
    @randomCommunities = []
    start = 0
    for comm, index in @finalData
      @randomCommunities.push randomOrder.slice(start, start + comm.length)
      start += comm.length
    @store.set {randomCommunities:@randomCommunities}
    @render()
