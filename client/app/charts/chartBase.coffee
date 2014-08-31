getWidth = ($elem) ->
  width = $elem.width()
  if width then return width
  $parent = $elem.parent()
  if $parent.length
    getWidth($parent)
  else
    throw new Error("can't get valid width")


View = require "views/view"
module.exports = class ChartBase extends View

  defaults:{}

  init: (options) ->
    @opts = _.defaults options, @defaults
    @once "visible", =>
      @normalizeOptions()
      @render()

  getWidth:  ->
    getWidth $(@opts.el)

  normalizeOptions: ->

  update: -> throw new Error "Update method not defined for this chart"

  showToolTip : (parent, selection, key = "name") =>
    if not @tooltip
      #we create only one tooltip instead of multiple instances
      @tooltip = parent.append("div")
      .attr("class", "tooltip")
      .style("opacity", 0)

    if _.isFunction(key)
      getter = key
    else
      getter = (d) -> _.capitalize(d[key])

    tooltipOver = (d) =>
      text = getter(d)
      @tooltip.transition()
      .duration(200)
      .style("opacity", 0.9)
      @tooltip.html(text)

    tooltipMove = =>
      @tooltip
      .style("left", (d3.event.layerX - 20) + "px")
      .style("top", (d3.event.layerY + 10) + "px")

    tooltipOut = (d) =>
      @tooltip.transition()
      .duration(200)
      .style("opacity",0)

    selection.on("mouseover", tooltipOver)
    .on("mouseout",tooltipOut)
    .on("mousemove", tooltipMove)

  #text for the bars charts
  toolTipText: (date,value) =>
    "#{value} communities"

  #creates the tooltips for the bar charts
  createToolTipBars: (el,plus,minus) ->

    @showToolTip d3.select(el), plus,(d) =>
      @toolTipText(d.date,d.plus)

    @showToolTip d3.select(el), minus,(d) =>
      @toolTipText(d.date,d.minus)

  getd3: (key, fn) ->
    (d) ->
      val = if key then d[key] else d
      if fn then fn(val) else val

