class ClassSizeBarGraph
  valueLabelWidth: 40  # space reserved for value labels (right)
  barHeight:       30  # height of one bar
  barLabelWidth:   100 # space reserved for bar labels
  barLabelPadding: 5   # padding between bar and bar labels (left)
  gridLabelHeight: 18  # space reserved for gridline labels
  gridChartOffset: 3   # space between start of grid and first bar
  maxBarWidth:     970 # width of the bar with the max value

  # Accessor functions
  barLabel: (d)  => d.name
  barValue: (d)  => parseFloat(d.registered)
  labelY: (d, i) => @barY(d, i) + @yScale().rangeBand() / 2
  barY: (d, i)   => @yScale()(i)
  barX: (d, i)   => @xScale()(d)

  # Scales
  yScale: =>
    d3.scale.ordinal().domain(d3.range(0, @data.length)).rangeBands([0, @data.length * @barHeight])
  xScale: =>
    d3.scale.linear().domain([0, d3.max(@data, (d) -> d.capacity)]).range([0, @maxBarWidth])

  constructor: (@data) ->
  chartWidth:  -> @maxBarWidth + @barLabelWidth + @valueLabelWidth
  chartHeight: -> @gridLabelHeight + @gridChartOffset + @data.length * @barHeight

  # Only call this once, it creates the containers
  draw: ->
    # Svg container element
    @chart =
      d3.select('body').append('svg').
         attr('width', @chartWidth()).
         attr('height', @chartHeight())

    # Bars
    @barsContainer =
      @chart.append('g').
       attr('transform', "translate(#{@barLabelWidth}, #{@gridLabelHeight + @gridChartOffset})")

    # Bar labels
    @labelsContainer =
      @chart.append('g').
        attr('transform', "translate(#{@barLabelWidth - @barLabelPadding}, #{@gridLabelHeight + @gridChartOffset})")

    # Warnings
    @warningsContainer =
      @chart.append('g').
        attr('transform', "translate(#{@barLabelWidth - @barLabelPadding}, #{@gridLabelHeight + @gridChartOffset})")

  update: (@data) ->
    @updateBars()
    @updateLabels()
    @updateWarnings()

    @chart.attr('width', @chartWidth()).
           attr('height', @chartHeight())

  updateWarnings: ->
    enter = @warningsContainer.selectAll('.warning').data(@data, (d) -> d.name).enter().
      append('g').
      attr('class', 'warning').
      attr('transform', (d, i) => "translate(#{@barX(@barValue(d))}, #{@barY(d, i)})")

    enter.append('text').
      attr('class', 'warning-text').
      attr('dx', '5px').
      attr('dy', '1.8em').
      attr('font-size', '11px').
      attr('color', 'white')

    enter.append('line').
      attr('class', 'warning-tick').
      attr('x1', 0).
      attr('x2', 0).
      attr('y1', 2).
      attr('y2', @barHeight - 2)

    warnings = @warningsContainer.selectAll('.warning').data(@data, (d) -> d.name)
    warnings.selectAll('text').
             text((d, i) -> d.warning)

  updateBars: ->
    # Add new bars
    @barsContainer.selectAll('.bar').data(@data, (d) -> d.name).enter().
      append('g').
      attr('class', 'bar').
      append('rect').
      attr('height', @yScale().rangeBand()).
      attr('width', 1).
      attr('class', 'registered-bar')

    # Get the selection
    bars = @barsContainer.selectAll('.bar').
      data(@data, (d) -> d.name).
      sort((a, b) -> d3.descending(a?.registered, b?.registered))

    # Update any that change
    # This is also applied to newly added elements
    bars.transition().
      attr('transform', (d, i) => "translate(0, #{@barY(d, i)})")

    bars.select('.registered-bar').transition().
      attr('width', (d) => @barX(@barValue(d)))

    # Remove any data that is no longer available
    bars.exit().remove()

  updateLabels: ->
    # Add new labels
    @labelsContainer.selectAll('text').
      data(@data, (d) -> d.name).
      enter().
      append('text').
      attr('stroke', 'none').
      attr('fill', 'black').
      attr('dy', '.35em').
      attr('text-anchor', 'end').
      attr('font-size', '10px').
      text(@barLabel)

    labels =
      @labelsContainer.selectAll('text').
        data(@data, (d) -> d.name).
        sort((a, b) -> d3.descending(a?.registered, b?.registered))

    # Move them depending on their updated position
    labels.transition().attr('y', @labelY)

    # Remove any data that is no longer available
    labels.exit().remove()

    # # Bar value labels
    # @barsContainer.selectAll("text").data(@data).enter().append("text").
    #   attr("x", (d) => @x(@barValue(d))).
    #   attr("y", @yText).
    #   attr("dx", 3). # padding-left
    #   attr("dy", ".35em"). # vertical-align: middle
    #   attr("text-anchor", "start"). # text-align: right
    #   attr("fill", "black").
    #   attr("stroke", "none").
    #   text((d) => d3.round(@barValue(d), 2))

draw = (data) ->
  @i ||= 0
  @i = @i + 1
  console.log("tick #{@i}")
  unless @graph?
    @graph = new ClassSizeBarGraph(data)
    @graph.draw()

  # Simulate changing data
  data[0].registered = 40 + Math.floor(Math.random() * (20 - 1 + 1)) + 1
  data[3].registered = 20 + Math.floor(Math.random() * (20 - 1 + 1)) + 1

  # Simulate adding a new element, and then removing it a bit later
  if @i >= 5 and @i <= 10
    data[data.length] =
      name: "English 405",
      capacity: 60,
      registered: 55
      warning: 55

  window.a = data
  @graph.update(data)

updateData = ->
  d3.json "/assets/classes.json", draw
  setTimeout(updateData, 3000)

updateData()
