BaseView = require "../view"
forceInt = require "../../libs/forceInt"
BarsLine = require "../../charts/barsLine"

dataMap = (result) ->
  final = []
  for a, b of result.count
    a = forceInt(a)
    if a is 80
      year = "#{a}-#{a+20}%"
    else year = "#{a}-#{a+19}%"
    final.push {plus:b.size, minus:0, year, sorter:a, communities:b.communities}
  final = _.sortBy final, (v) ->
    v.sorter
  return final

module.exports = class View extends BaseView
  template: require("./templates/correlationDetail")

  onClick: (d, i) =>
    @store.filter.groupings.communities = d.communities
    @store.filter.filters = {}
    @store.filter.attributes = [@options.question]
    Backbone.trigger "communitiesFiltered"

  afterRender: =>
    chart = new BarsLine
      data:@options.data
      el:@$('.graph')[0]
      processData: dataMap
      height:250
      width:400
      onClick:@onClick
    chart.trigger("visible")

  getRenderData: =>
    if @options.probability then displayProbability = true
    probability = @options.probability?[@options.data.val]?.toFixed(2) ? 0
    nonRandomChance = @options.probability?.nonRandomChance?[@options.data.val]?.toFixed(2) ? 0
    totalProbability = @options.probability?.totalProbability?[@options.data.val]?.toFixed(2) ? 0
    {title:@options.data.answerText, probability, nonRandomChance, totalProbability, displayProbability}
