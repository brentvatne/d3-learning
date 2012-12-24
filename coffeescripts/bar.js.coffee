class ClassSizeBarGraph
  valueLabelWidth: 40  # space reserved for value labels (right)
  barHeight:       20  # height of one bar
  barLabelWidth:   100 # space reserved for bar labels
  barLabelPadding: 5   # padding between bar and bar labels (left)
  gridLabelHeight: 18  # space reserved for gridline labels
  gridChartOffset: 3   # space between start of grid and first bar
  maxBarWidth:     420 # width of the bar with the max value

  # Accessor functions
  barLabel: (d)  => d.name
  labelY: (d, i) => @y(d, i) + @yScale().rangeBand() / 2

  barValue: (d)  => parseFloat(d.registered)
  y:      (d, i) => @yScale()(i)
  x:      (d, i) => @xScale()(d)

  # Scales
  yScale: =>
    d3.scale.ordinal().domain(d3.range(0, @data.length)).rangeBands([0, @data.length * @barHeight])

  xScale: =>
    d3.scale.linear().domain([0, d3.max(@data, @barValue)]).range([0, @maxBarWidth])

  constructor: (@data) ->

  chartWidth: ->
    @maxBarWidth + @barLabelWidth + @valueLabelWidth

  chartHeight: ->
    @gridLabelHeight + @gridChartOffset + @data.length * @barHeight

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

  update: (@data) ->
    bars =
      @barsContainer.selectAll('.bar').
        data(@data, (d) -> d.name).
        sort((a, b) -> d3.descending(a?.registered, b?.registered))

    # Add new bars
    bars.enter().
      append('g').
      attr('class', 'bar').
      append('rect').
      attr('height', @yScale().rangeBand()).
      attr('width', 1).
      attr('class', 'registered-bar')

    # Update any that change
    # This is also applied to newly added elements
    bars.transition().
      attr('transform', (d, i) => "translate(0, #{@y(d, i)})")

    bars.select('.registered-bar').transition().
      attr('width', (d) => @x(@barValue(d)))

    labels =
      @labelsContainer.selectAll('text').
        data(@data).
        sort((a, b) -> d3.descending(a?.registered, b?.registered))

    labels.enter().append('text').
      attr('stroke', 'none').
      attr('fill', 'black').
      attr('dy', ".35em").
      attr('text-anchor', 'end').
      attr('font-size', '10px').
      text(@barLabel)

    labels.transition().
      attr('y', @labelY)

    @chart.attr('width', @chartWidth()).
           attr('height', @chartHeight())

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
  console.log('tick')
  @i ||= 1
  unless @graph?
    @graph = new ClassSizeBarGraph(data)
    @graph.draw()
  data[0].registered = 40 +  Math.floor(Math.random() * (20 - 1 + 1)) + 1

  if @i % 5 == 0
    data[data.length] =
      name: "English #{i}",
      capacity: 60,
      registered: 55
      warning: 55
  else
    @i = @i + 1

  window.a = data
  @graph.update(data)

updateData = ->
  d3.json "/assets/classes.json", draw
  setTimeout(updateData, 1000)

updateData()
