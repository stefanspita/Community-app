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

  #  constructor: (options) ->

  defaults:{}

  init: (options) ->
    @opts = _.defaults options, @defaults
    @once "visible", =>
      @normalizeOptions()
      @render()

  messages:
    monthly:"Click for more details."

  getWidth:  ->
    getWidth $(@opts.el)

  normalizeOptions: ->

  update: -> throw new Error "Update method not defined for this chart"

  floatMap: (key, array) ->
    for item in array
      item[key] = parseFloat item[key]

  dateMap: (key, array, format = "YYYY-MM-DD") ->
    for item in array
      item[key] = moment(item[key], format).toDate()

  drawSpinSelector: (position) ->
    switch position
      when "bottom"
        x = 0
        y = @radius
        width = 3
        height = 10
        angle = 0
        @angle = 180
        triangleX = x + 1.5
        triangleY = y + height
      else
      # right
        x = @radius
        y = 0
        width = 10
        height = 3
        @angle = 90
        angle = -90
        triangleX = y - 1.5
        triangleY = x + (width - 5)

    @arrowRect = @mainG.append("rect")
    .attr("height", height)
    .attr("x", x)
    .attr("y", y)
    .attr("width", width)
    .style("fill","black")
    .attr("opacity",0)


    @arrowTriangle = @mainG.insert("path", ":first-child")
    .attr("d", d3.svg.symbol().type("triangle-down").size(400))
    .attr("transform", "rotate(#{angle}), translate(#{triangleX},#{triangleY})")
    .style("fill","black")
    .attr("opacity",0)

  #@arrowTriangle.transition().duration(1000).attr("opacity",1)
  #@arrowRect.transition().duration(1000).attr("opacity",1)


  onStop: (angle) =>
    if angle?
      @lastAngle = angle
    else
      angle = @lastAngle
    angle = @angle - angle
    if angle > 360
      angle -= 360
    else if angle < 0
      angle += 360


    elems = @group.filter (d) =>
      start = @degrees(d.startAngle)
      end = @degrees(d.endAngle)
      start <= angle <= end
    elems.each (d) =>
      #@arrowRect.transition().duration(750).style("fill", @color(d.data.label) )
      @arrowTriangle.transition().duration(750).style("fill", @color(d.data.label) )
      @trigger "select", d.data

  degrees : (radians) ->
    radians * (180 / Math.PI)

  radians : (degrees) ->
    degrees / 180 * Math.PI

  getAngle : (x, y) ->
    a = @degrees Math.atan2(x, y)
    if a < 0 then a += 360
    a

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
      text=getter(d)
      if text isnt "" #in some cases we send an empty text to not show the tooltip
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
  toolTipText: (date,value,text="",textAfter="") => #optional label before the amount
    day=if @opts.formatToolTipDate isnt "" then moment(date).format(@opts.formatToolTipDate) else ""
    text= text+"</br>" if text? and text isnt ""
    "#{value} communities"

  #creates the tooltips for the bar charts
  createToolTipBars: (el,plus,minus) ->

    @showToolTip d3.select(el), plus,(d) =>
      textAfter= if @opts.monthlyView and d.monthly then @messages["monthly"] else ""
      after= @opts.monthlyView and d.monthly
      @toolTipText(d.date,d.plus,d.text,textAfter)

    @showToolTip d3.select(el), minus,(d) =>
      textAfter= if @opts.monthlyView and d.monthly then @messages["monthly"] else ""
      @toolTipText(d.date,d.minus,d.text,textAfter)

  showLegends : ({el,colorScale, data, labelKey}) =>
    holder = d3.select(el).append("div").attr("class","legendHolder")
    g = holder.selectAll(".legend")
    .data(data)
    .enter().append("div")
    .attr("class", "legend")
    g.append("span")
    .style("background", @getd3(labelKey, colorScale))
    .attr("class","key")
    g.append("span")
    .text(@getd3(labelKey))
    .attr("class","label")
    d3.select(el).append("div").attr("class","clearfix")


  getd3: (key, fn) ->
    (d) ->
      val = if key then d[key] else d
      if fn then fn(val) else val

  formatCurrency: (number) ->
    number = @addCommas(number)
    if @opts.suffixToolTip
      prefix=""
      suffix=@opts.suffixToolTip
    else
      prefix=@opts.prefixToolTip
      suffix=""
    if number and number isnt "NaN"
      "#{prefix}#{number}#{suffix}"
    else
      ""

  addCommas: (number) =>
    if(number>1000000000)
      number = number / 1000000
      number = Math.round(number)
      number = number / 1000
      number = "" + number + "B"
    else
      if(number > 10000000)
        number = number / 1000
        number = Math.round(number)
        number = number / 1000
        number = "" + number + "M"
      else
        number = @round(number)
        number += ""
        x = number.split(".")
        x1 = x[0]
        x2 = (if x.length > 1 then "." + x[1] else "")
        if x2.length is 2
          x2 += "0"
        rgx = /(\d+)(\d{3})/
        x1 = x1.replace(rgx, "$1" + "," + "$2")  while rgx.test(x1)
        number = x1 + x2
    number

  round: (val) ->
    Math.round(val * 100) / 100

  sum: (array, key) ->
    total = 0
    for item in array
      if key
        total+= parseFloat(_.result item, key)
      else
        total += item
    total

  forceInt: (str) ->
    str = "#{str}".replace(/,/g,"").replace(/\s/g,"").replace(/%/g,"")
    out = Math.round str
    out = 0 if _.isNaN(out)
    out



