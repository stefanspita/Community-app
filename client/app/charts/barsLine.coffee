colors = require "./colors"
Base = require "./chartBase"

module.exports = class BarsOrdinalScale extends Base

  defaults :
    width:700
    height:350
    margin:
      top: 10
      right: 10
      bottom: 40
      left: 40
    margin2:
      top:330
      right:10
      bottom:20
      left:40
    maxTicks:20

  data:[]
  onClick: ->

  processData: (raw) ->
    raw

  normalizeOptions: ->
    @margin = @opts.margin
    if @opts.yKey2
      @margin.right = 40
    if @opts.width is "auto"
      @opts.width = @getWidth()
    @width = @opts.width - @margin.left - @margin.right
    @height = @opts.height - @margin.top - @margin.bottom
    if @opts.rawData? #the raw data is to keep the data unmodified and only give a function as a parameter to the update function
      @opts.data=@opts.rawData
    if @opts.processData?
      @processData=@opts.processData

  setupScales: ->
    format = d3.format("s")
    @xbar = d3.scale.ordinal().rangeRoundBands([0, @width], .1)
    @y = d3.scale.linear().range([(@height), (0)])
    @xAxis = d3.svg.axis().scale(@xbar).orient("bottom").tickSize(0)
    @yAxis = d3.svg.axis().scale(@y).orient("left").tickFormat(format).ticks(5).tickSize(0)
    if @options.xFormat #the format to the x axis can be set
      @xAxis.tickFormat(@options.xFormat)

  colors: ->
    blues = colors.blue
    reds = colors.orange
    @color = d3.scale.linear().range([blues[4], blues[0]])
    @colorRed = d3.scale.linear().range([reds[0], reds[2]])


  createsvg: ->
    @svg = d3.select(@opts.el)
    .append("svg")
    .attr("width", @width + @margin.left + @margin.right)
    .attr("height", @height + @margin.top + @margin.bottom)

  appendBars: ->
    @svg.append("defs").append("clipPath")
    .attr("id", "clip")
    .append("rect")
    .attr("width", @width)
    .attr("height", @height)

    @focus = @svg.append("g")
    .attr("transform", "translate(" + @margin.left + "," + @margin.top + ")")
    @bars = @focus.append("g")


  appendText: ->
    @xg = @focus.append("g")
    .attr("class", "x axis yw-charts")
    .attr("transform", "translate(0," + @y(0) + ")")
    .call(@xAxis)

    @yg = @focus.append("g")
    .attr("class", "y axis yw-charts")
    .call(@yAxis)

  obtainMaxTicks: () =>
    @maxTicks = @opts.maxTicks

  render: ->
    @setupScales()
    @colors()
    @createsvg()
    @appendBars()
    @appendText()
    @obtainMaxTicks()
    @update(@opts.data)

  update: (args...) ->
    freshData = args[0]
    if _.isFunction(freshData)
      data= if @opts.rawData then @opts.rawData else @opts.data
      @opts.data = freshData(data)
    else
      @opts.data=freshData
      @opts.data = @processData(@opts.data)

    return unless @y
    @updateMinMax()
    @updateYears()
    @updatePlusBars()
    @updateMinBars()
    @updateAxis()
    @createToolTipBars(@opts.el,@plus,@minus)

  updateMinMax: =>
    max = d3.max @opts.data, @getd3("plus")
    min = d3.min @opts.data, @getd3("minus")
    max *= 1.2
    yExtent = [min, max]
    @y.domain(yExtent)
    if @color.domain
      @color.domain [0, max]
      @colorRed.domain [min, 0]

  updateYears: ->
    years = _.pluck @opts.data, "year"
    if years.length > @maxTicks
      skip = Math.ceil(years.length / @maxTicks)
      @xAxis.tickValues (year for year in years by skip)
    @xbar.domain years

  getColorMinus: (d) =>
    @colorRed(d.minus)

  getColorPlus: (d) =>
    @color(d.plus)

  onEnterX: (d) => @xbar(d.year)

  onExitX: (d) => @xbar(d.year)

  onY: => @y(0)

  onHeight: -> 0

  onMinusHeight: -> 0

  onMinusY: => @y(0)

  onFill: (d) => @getColorPlus(d)

  onFillMinus: (d) => @getColorMinus(d)

  getMinHeight: -> 5

  updatePlusBars: ->
    @plus = @bars.selectAll(".plus").data(@opts.data,(d) -> d.date)

    @plus.enter().append("rect")
    .attr("class", "plus")
    .attr("x", @onEnterX)
    .attr("width", @xbar.rangeBand())
    .attr("y", @onY)
    .attr("height", @onHeight)
    .attr("fill", @onFill)
    .on "click", @opts.onClick

    @plus.transition().duration(1000)
    .attr("y", (d) => @y(d.plus) - @getMinHeight(d))
    .attr("height",(d) => @y(0) - @y(d.plus) + @getMinHeight(d) )
    .attr("fill", @onFill)
    .attr("x", (d) => @xbar(d.year))
    .attr("width", @xbar.rangeBand())

    @plus.exit().transition().duration(1000)
    .attr("y", @onY)
    .attr("x", @onExitX)
    .attr("height", @onHeight)
    .remove()

  updateMinBars: ->
    @minus = @bars.selectAll(".minus").data(@opts.data,(d) -> d.date)

    @minus.enter().append("rect")
    .attr("class", "minus")
    .attr("x", @onEnterX)
    .attr("width", @xbar.rangeBand())
    .attr("y", @onMinusY)
    .attr("height", @onMinusHeight)
    .attr("fill", @onFillMinus)
    .on "click", @opts.onClick

    @minus.transition().duration(1000)
    .attr("y", @y(0))
    .attr("height", (d) => @y(d.minus) - @y(0))
    .attr("fill",@onFillMinus)
    .attr("x", (d) => @xbar(d.year))
    .attr("width", @xbar.rangeBand())

    @minus.exit().transition().duration(1000)
    .attr("y", @onMinusY)
    .attr("x", @onExitX)
    .attr("height", @onMinusHeight)
    .remove()

  updateAxis: ->
    @updateYears()
    @xg.transition().duration(1000)
    .attr("transform", "translate(0," + @y(0) + ")")
    .call(@xAxis)
    .each "end", ->
      d3.select(this).selectAll("g")
      .attr("stroke",(d) -> "#3e7ba1")

      d3.select(this).selectAll("g").insert("rect", "text")
      .attr("width", 36)
      .attr("height", 12)
      .attr("x", -18)
      .attr("fill",(d) -> "white")
      .attr("opacity",0.85)

    @yg.transition().duration(1000).call(@yAxis)
