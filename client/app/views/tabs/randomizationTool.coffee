BaseView = require "../view"

module.exports = class View extends BaseView
  template: require("../../templates/tabs/randomizationTool")

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
    nodesInComms = Math.round(randomOrder.length / @finalData.length)
    @randomCommunities = _.values(_.groupBy randomOrder, (node, index) ->
      return Math.floor(index / nodesInComms))
    @store.set {randomCommunities:@randomCommunities}
    @render()
