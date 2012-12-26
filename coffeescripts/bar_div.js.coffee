class ClassSizeBarGraph
  valueLabelWidth: 40  # Space reserved for value labels (right)
  barHeight:       30  # Height of one bar
  barLabelWidth:   100 # Space reserved for bar labels
  barLabelPadding: 5   # Padding between bar and bar labels (left)
  gridLabelHeight: 18  # Space reserved for gridline labels
  gridChartOffset: 3   # Space between start of grid and first bar
  maxBarWidth:     970 # Width of the bar with the max value

  # Accessor functions
  barLabel: (d)  => d.name
  barValue: (d)  => d.registered
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
  chartHeight: -> @gridLabelHeight + @gridChartOffset + @data.length * @barHeight + 200

  # Only call this once, it creates the containers
  draw: ->
    # Div container element
    @chart =
      d3.select('body').append('div').
       attr('class', 'chart-container').
       attr('style', """
         height: #{@chartHeight()}px; width: #{@chartWidth()}px; position: relative;
       """)

    # Bars
    @barsContainer =
      @chart.append('div').
        attr('class', 'bars-container').
        attr('style', """
          margin-left: #{@barLabelWidth}px; margin-top: #{@gridLabelHeight + @gridChartOffset}px;
          height: #{@chartHeight()}px; width: #{@chartWidth()}px;
        """)

    # Bar labels
    @labelsContainer =
      @chart.append('div').
        attr('class', 'bar-labels').
        attr('style', """
          left: #{@barLabelPadding}px;
          top: 0px;
        """)

    # # Warnings
    # @warningsContainer =
    #   @chart.append('div').
    #     attr('class', 'warnings-container').
    #     style('position', 'absolute').
    #     style('left', @barLabelWidth - @barLabelPadding).
    #     style('top', @gridLabelHeight + @gridChartOffset)

    # # Warnings
    # @capacitiesContainer =
    #   @chart.append('div').
    #     attr('class', 'warnings-container').
    #     style('position', 'absolute').
    #     style('left', @barLabelWidth - @barLabelPadding).
    #     style('top', @gridLabelHeight + @gridChartOffset)

    # @xAxis  =
    #   @chart.append('g').
    #     attr('class', 'axis x-axis').
    #     call(d3.svg.axis().scale(@xScale()))

  update: (@data) ->
    @updateBars()
    @updateLabels()
    # @updateWarnings()
    # @updateCapacities()

    @chart.attr('width', @chartWidth()).
           attr('height', @chartHeight())

    # @xAxis.attr('transform', "translate(#{@barLabelWidth}, #{@chartHeight() - 190})")

  updateBars: ->
    # Add new bars
    @barsContainer.selectAll('.registered-bar').data(@data, (d) -> d.name).enter().
      append('div').
      attr('class', 'bar').
      append('div').
      attr('class', 'registered-bar').
      style('width', 1)

    # Get the selection
    bars = @barsContainer.selectAll('.bar').
      data(@data, (d) -> d.name).
      sort((a, b) -> d3.descending(a?.name, b?.name))

    # Update any that change
    # This is also applied to newly added elements
    bars.attr('style', (d, i) => """
        width: #{@barX(@barValue(d))}px; height: #{@yScale().rangeBand()}px;
        left: 0px; top: #{@barY(d, i)}px
      """)

    bars.select('.registered-bar').transition().
      attr('style', (d, i) => "width: #{@barX(@barValue(d))}px; height: #{@yScale().rangeBand()}px").
      attr('class', (d, i) ->
        if d.registered >= d.capacity
          'registered-bar at-capacity'
        else if d.registered >= d.warning
          'registered-bar at-warning'
        else
          'registered-bar'
      )

    # Remove any data that is no longer available
    bars.exit().remove()

  updateLabels: ->
    # Add new labels
    @labelsContainer.selectAll('.bar-label').
      data(@data, (d) -> d.name).
      enter().
      append('div').
      attr('class', 'bar-label').
      text(@barLabel)

    labels =
      @labelsContainer.selectAll('.bar-label').
        data(@data, (d) -> d.name).
        sort((a, b) -> d3.descending(a?.name, b?.name))

    # Move them depending on their updated position
    labels.attr('style', """
        top: 0.35em;
        height: #{@barHeight}px;
        line-height: #{@barHeight}px;
    """)

    # Remove any data that is no longer available
    labels.exit().remove()

  updateCapacities: ->
    enter = @capacitiesContainer.selectAll('.capacity').data(@data, (d) -> d.name).enter().
      append('g').
      attr('class', 'capacity')

    enter.append('text').
      attr('class', 'capacity-text').
      attr('dx', '1px').
      attr('dy', '1.2em').
      attr('font-size', '11px').
      attr('color', 'white')

    enter.append('line').
      attr('class', 'capacity-tick').
      attr('x1', 5).
      attr('x2', 5).
      attr('y1', 18).
      attr('y2', @barHeight - 1)

    # Update
    capacities =
      @capacitiesContainer.selectAll('.capacity').data(@data, (d) -> d.name).
      sort((a, b) -> d3.descending(a?.name, b?.name))

    capacities.attr('transform', (d, i) => "translate(#{@barX(d.capacity)}, #{@barY(d, i)})")
    capacities.selectAll('text').text((d, i) -> d.capacity)
    capacities.selectAll('line')

  updateWarnings: ->
    # Create
    enter = @warningsContainer.selectAll('.warning').data(@data, (d) -> d.name).enter().
      append('g').
      attr('class', 'warning')

    enter.append('text').
      attr('class', 'warning-text').
      attr('dx', '2px').
      attr('dy', '1.2em').
      attr('font-size', '11px').
      attr('color', 'white')

    enter.append('line').
      attr('class', 'warning-tick').
      attr('x1', 5).
      attr('x2', 5).
      attr('y1', 18).
      attr('y2', @barHeight - 1)

    # Update
    warnings =
      @warningsContainer.selectAll('.warning').data(@data, (d) -> d.name).
      sort((a, b) -> d3.descending(a?.name, b?.name))

    warnings.attr('transform', (d, i) => "translate(#{@barX(d.warning)}, #{@barY(d, i)})")

    warnings.selectAll('text').
             text((d, i) -> d.warning)


draw = (data) ->
  @i ||= 0
  @i = @i + 1

  # Initialize the graph if it's the first time
  unless @graph?
    @graph = new ClassSizeBarGraph(data)
    @graph.draw()

  # Simulate changing data
  data[0].registered = 40 + Math.floor(Math.random() * (80 - 1 + 1)) + 1
  data[3].registered = 20 + Math.floor(Math.random() * (80 - 1 + 1)) + 1
  data[1].registered = 20 + Math.floor(Math.random() * (80 - 1 + 1)) + 1
  data[5].registered = 0 + Math.floor(Math.random() * (80 - 1 + 1)) + 1

  # Simulate adding a new element, and then removing it a bit later
  if @i >= 5 and @i <= 10
    data[data.length] =
      name: "English 405",
      capacity: 60,
      registered: 55
      warning: 55

  @graph.update(data)

(updateData = ->
  d3.json "/assets/classes.json", draw
  setTimeout(updateData, 2000)
)()
