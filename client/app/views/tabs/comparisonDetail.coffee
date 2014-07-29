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
  template: require("./templates/comparisonDetail")

  onClick: (d, i) =>
    @store.filter.groupings.communities = d.communities
    @store.filter.filters = {}
    @store.filter.attributes = [@options.question]
    Backbone.trigger "communitiesFiltered"

  afterRender: =>
    chart1 = new BarsLine
      data:@options.realData
      el:@$('.graph1')[0]
      processData: dataMap
      height:250
      width:400
      onClick:@onClick
    chart2 = new BarsLine
      data:@options.randomData
      el:@$('.graph2')[0]
      processData: dataMap
      height:250
      width:400

    chart1.trigger("visible")
    chart2.trigger("visible")

  getRenderData: =>
    {title:@options.realData.answerText}
