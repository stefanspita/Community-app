BaseView = require "../view"

module.exports = class View extends BaseView
  template: require("../../templates/tabs/randomizationTool")

  events:
    "click a.randomize":"randomize"

  init: ->
    @finalData = @options.finalData
    @nodesList = _.unique(_.flatten(@finalData))

  getRenderData: ->
    { numberOfNodes:@nodesList.length }

  randomize: ->
    randomOrder = _.sample(@nodesList, @nodesList.length)
    nodesInComms = Math.round(randomOrder.length / @finalData.length)
    randomComms = _.values(_.groupBy randomOrder, (node, index) ->
      return Math.floor(index / nodesInComms))
    console.log randomComms
