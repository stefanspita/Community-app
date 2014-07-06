defaults =
  width:700
  height:350
  margin:
    top: 10
    right: 10
    bottom: 50
    left: 40
  margin2:
    top:330
    right:10
    bottom:20
    left:40

  xKey:"date"
  yKey:"balance"
  data:[]
  eventData:[]
  eventChange: ->
  onClick: ->
  processData: (raw) ->
    for item in raw
      plus = item.plus
      minus = item.minus
      year = item.year
      line = item.line
      {plus, minus, year, line}

colors = require("./colors")

module.exports = (opts) ->

  defaultWidth = 700
  options = _.extend {}, defaults, {width:defaultWidth}, opts
  {margin, margin2} = options

  if options.yKey2
    margin.right = 40

  width = options.width - margin.left - margin.right
  height = options.height - margin.top - margin.bottom
  formatPercent = d3.format("s")

  xbar = d3.scale.ordinal().rangeRoundBands([0, width], .1)
  y = d3.scale.linear().range([(height), (0)])

  blues = colors.blue
  blue1 = opts.blue1 ? blues[0]
  blue2 = opts.blue2 ? blues[4]
  colorInterpolate = d3.interpolateRgb(blue1, blue2)
  colorScale = d3.scale.linear().range([1,0])
  colorScaleMinus = d3.scale.linear().range([1,0])
  color =  (y) ->
    colorInterpolate colorScale y

  reds = colors.orange
  red1 = opts.red1 ? reds[0]
  red2 = opts.red2 ? reds[2]
  redInterpolate = d3.interpolateRgb(red1, red2)
  colorRed =  (y) ->
    redInterpolate colorScaleMinus y


  xAxis = d3.svg.axis().scale(xbar).orient("bottom")
  .tickSize(6)


  yAxis = d3.svg.axis().scale(y).orient("left").tickFormat(formatPercent).ticks(5)

  svg = d3.select(options.elem)
  .append("svg")
  .attr("width", width + margin.left + margin.right)
  .attr("height", height + margin.top + margin.bottom)

  svg.append("defs").append("clipPath")
  .attr("id", "clip")
  .append("rect")
  .attr("width", width + 50)
  .attr("height", height)

  focus = svg.append("g")
  .attr("transform", "translate(" + margin.left + "," + margin.top + ")")


  data = options.processData(options.data)

  years = _.pluck data, "year"
  xbar.domain years
  maxTicks = 20

  if years.length > maxTicks
    skip = Math.round(years.length / maxTicks)
    xAxis.tickValues (year for year in years by skip)

  max = d3.max data, d3.get("plus")
  min = d3.min data, d3.get("minus")

  yExtent = [min, max]
  y.domain( yExtent )
  colorScale.domain [0, max]
  colorScaleMinus.domain [min, 0]

  plus = focus.selectAll(".plus")
  .data(data)
  .enter().append("rect")
  .attr("class", "plus")
  .attr("x", (d) -> xbar(d.year))
  .attr("width", xbar.rangeBand())
  .attr("y", (d) -> y(0))
  .attr("height", 0)
  .attr("fill", (d) -> color(d.plus))
  .on "click", options.onClick

  minus = focus.selectAll(".minus")
  .data(data)
  .enter().append("rect")
  .attr("class", "minus")
  .attr("x", (d) -> xbar(d.year))
  .attr("width", xbar.rangeBand())
  .attr("y", (d) -> y(0))
  .attr("height", 0)
  .attr("fill", (d) -> colorRed(d.minus))
  .on "click", options.onClick

  do draw = ->
    plus.transition()
    .delay((d,i) -> i * 50)
    .duration(1000)
    .attr("y", (d) -> y(d.plus))
    .attr("height", (d) -> y(0) - y(d.plus))
    minus.transition()
    .delay((d,i) -> i * 50)
    .duration(1000)
    .attr("y", y(0))
    .attr("height", (d) -> y(d.minus) - y(0))


  xg = focus.append("g")
  .attr("class", "x axis withRect")
  .attr("transform", "translate(0," + y(0) + ")")
  .call(xAxis)

  xg.selectAll("g").insert("rect", "text")
  .attr("width", 55)
  .attr("height", 14)
  .attr("x", -58)
  .attr("rx",3)
  .attr("ry",3)
  .attr("fill","#66E0FF")
  .attr("transform", "rotate(-45)")

  xg.selectAll("text")
  .style("text-anchor", "end")
  .style("font-size", "12px")
  .attr("dx", "-.8em")
  .attr("dy", ".15em")
  .attr("transform", "rotate(-45)")


  yg = focus.append("g")
  .attr("class", "y axis")
  .call(yAxis)

  if options.line
    xpad = xbar.rangeBand() / 2
    line = d3.svg.line()
    .x( (d) -> xpad + xbar(d.year))
    .y( d3.get("line", y))
    netLine = focus.append("path")
    .datum(data)
    .attr("d", line)
    .attr("class", "line")
    .style("stroke", "#506930")
    .style("stroke-width","5px")


  (freshData) ->
    if _.isFunction(freshData)
      data = freshData(options.data)
    else
      data = options.processData(freshData)

    max = d3.max data, d3.get("plus")
    min = d3.min data, d3.get("minus")
    yExtent = [min, max]
    y.domain(yExtent)
    colorScale.domain [0, max]
    colorScaleMinus.domain [min, 0]


    plus.data(data)
    .transition().duration(1000)
    .delay((d,i) -> i * 50)
    .attr("y", (d) -> y(d.plus))
    .attr("height", (d) -> y(0) - y(d.plus))
    .attr("fill", (d) -> color(d.plus))

    minus.data(data)
    .transition().duration(1000)
    .delay((d,i) -> i * 50)
    .attr("y", y(0))
    .attr("height", (d) -> y(d.minus) - y(0))
    .attr("fill", (d) -> colorRed(d.minus))

    xg.transition().duration(1000)
    .attr("transform", "translate(0," + y(0) + ")")
    yg.transition().duration(1000).call(yAxis)

    if netLine
      netLine.datum(data)
      .transition().duration(2000).attr("d", line)