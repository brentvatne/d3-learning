draw = (data) ->
  valueLabelWidth = 40  # space reserved for value labels (right)
  barHeight       = 20  # height of one bar
  barLabelWidth   = 100 # space reserved for bar labels
  barLabelPadding = 5   # padding between bar and bar labels (left)
  gridLabelHeight = 18  # space reserved for gridline labels
  gridChartOffset = 3   # space between start of grid and first bar
  maxBarWidth     = 420 # width of the bar with the max value

  # Accessor functions
  barLabel = (d) -> d.name
  barValue = (d) -> parseFloat(d.capacity)

  # Scales
  yScale = d3.scale.ordinal().domain(d3.range(0, data.length)).rangeBands([0, data.length * barHeight])
  yText  = (d, i) -> y(d, i) + yScale.rangeBand() / 2
  y      = (d, i) -> yScale(i)
  x      = d3.scale.linear().domain([0, d3.max(data, barValue)]).range([0, maxBarWidth])

  # Svg container element
  chart =
    d3.select('body').append("svg").
       attr('width', maxBarWidth + barLabelWidth + valueLabelWidth).
       attr('height', gridLabelHeight + gridChartOffset + data.length * barHeight)

  # Grid line labels
  gridContainer =
    chart.append('g').
          attr('transform', "translate(#{barLabelWidth}, #{gridLabelHeight})")

  gridContainer.selectAll("text").data(x.ticks(10)).enter().append("text").
    attr("x", x).
    attr("dy", -3).
    attr("text-anchor", "middle").
    text(String)

  # Vertical grid lines
  gridContainer.selectAll("line").data(x.ticks(10)).enter().append("line").
    attr("x1", x).
    attr("x2", x).
    attr("y1", 0).
    attr("y2", yScale.rangeExtent()[1] + gridChartOffset).
    style("stroke", "#ccc")

  # Bar labels
  labelsContainer =
    chart.append('g').
     attr('transform', 'translate(' + (barLabelWidth - barLabelPadding) + ',' + (gridLabelHeight + gridChartOffset) + ')')

  labelsContainer.selectAll('text').data(data).enter().append('text').
    attr('y', yText).
    attr('stroke', 'none').
    attr('fill', 'black').
    attr("dy", ".35em").
    attr('text-anchor', 'end').
    text(barLabel)

  # Bars
  barsContainer =
    chart.append('g').
     attr('transform', 'translate(' + barLabelWidth + ',' + (gridLabelHeight + gridChartOffset) + ')')

  barsContainer.selectAll("rect").data(data).enter().append("rect").
    attr('y', y).
    attr('height', yScale.rangeBand()).
    attr('width', (d) -> x(barValue(d))).
    attr('stroke', 'white').
    attr('fill', 'steelblue')

  # Bar value labels
  barsContainer.selectAll("text").data(data).enter().append("text").
    attr("x", (d) -> x(barValue(d))).
    attr("y", yText).
    attr("dx", 3). # padding-left
    attr("dy", ".35em"). # vertical-align: middle
    attr("text-anchor", "start"). # text-align: right
    attr("fill", "black").
    attr("stroke", "none").
    text((d) -> d3.round(barValue(d), 2))

  # Start line
  barsContainer.append("line").
    attr("y1", -gridChartOffset).
    attr("y2", yScale.rangeExtent()[1] + gridChartOffset).
    style("stroke", "#000")

d3.json "/assets/classes.json", draw
