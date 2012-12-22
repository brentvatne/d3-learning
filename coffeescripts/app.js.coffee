getHours = (xml_date) ->
  date = new Date(xml_date)
  date.getUTCHours()

getDay = (xml_date) ->
  date = new Date(xml_date)
  date.getUTCDay()

draw = (tweets) ->
  hourMax    = d3.max(tweets, (d) -> getHours(d.created_at))
  dayMax     = d3.max(tweets, (d) -> getDay(d.created_at))
  retweetMax = d3.max(tweets, (d) -> d.retweet_count)

  # x axis scale
  hourScale    = d3.scale.linear().domain([0, hourMax]).range([30, 500])
  # y axis scale
  dayScale     = d3.scale.linear().domain([dayMax, 0]).range([30, 300])
  # radius scale
  retweetScale = d3.scale.linear().domain([0, retweetMax]).range([5, 20])

  d3.select('body').
     append('svg').
     selectAll('circle').
     data(tweets).
     enter().
     append('circle').
     attr('title', (d) -> d.text)

  d3.selectAll('circle').
     attr('cx', (d) -> hourScale(getHours(d.created_at))).
     attr('cy', (d) -> dayScale(getDay(d.created_at))).
     attr('r',  (d) -> retweetScale(d.retweet_count))

  xAxis = d3.svg.axis().scale(hourScale)
  yAxis = d3.svg.axis().scale(dayScale).orient('left').tickFormat(d3.format('d'))
  svg   = d3.select('svg')

  # Append a svg group for each axis
  svg.append('svg:g').
      attr('class', 'axis x-axis').
      attr('transform', "translate(0,300)").
      call(xAxis)

  svg.append('svg:g').
      attr('class', 'axis y-axis').
      attr('transform', 'translate(30,0)').
      call(yAxis)

  # d3.selectAll('circle').
  #   on('mouseover', (d) ->
  #     svg.append('text').
  #         attr('x', hourScale(getHours(d.created_at)) + 15).
  #         attr('y', dayScale(getDay(d.created_at)) + 10).
  #         text(d.text).
  #         attr('class', 'tooltip')).
  #   on('mouseout', (d) ->
  #     d3.selectAll('.tooltip').remove())

  $('svg circle').tipsy
    gravity: 'w'
    html: true
    title: -> @__data__.text

d3.json "/assets/tweets.json", draw
