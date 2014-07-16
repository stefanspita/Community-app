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
    Backbone.trigger "communitiesFiltered", d.communities

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
    {title:@options.data.answerText}
