BaseView = require "../view"
forceInt = require "../../libs/forceInt"
BarsLine = require "../../charts/barsLine"

dataMap = (result) ->
  final = []
  for a, b of result.count
    unless a in ["false", "0.00"]
      final.push {plus:b, minus:0, year:a}
  final = _.sortBy final, (v) ->
    forceInt(v.year)
  return final

module.exports = class View extends BaseView
  template: require("../../templates/tabs/correlationDetail")

  afterRender: =>
    BarsLine
      data:@options.data
      elem:@$('.graph')[0]
      processData: dataMap
      height:250
      width:400

  getRenderData: =>
    {title: @options.title}
