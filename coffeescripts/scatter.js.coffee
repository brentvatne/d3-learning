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
     selectAll('circle.tweet').
     data(tweets).
     enter().
     append('circle').
     attr('class', 'tweet').
     attr('title', (d) -> d.text)

  d3.selectAll('circle.tweet').
     attr('cx', (d) -> hourScale(getHours(d.created_at))).
     attr('cy', (d) -> dayScale(getDay(d.created_at))).
     attr('r',  0).
     attr('class', 'tweet').
     attr('opacity', 0.5).
     transition().
     attr('r',  (d) -> retweetScale(d.retweet_count))

  d3.selectAll('circle.tweet').on('mouseover', (d, i) ->
    d3.select(this).
      attr('stroke-width', 1).
      transition().
      attr('stroke-width', 2).
      attr('opacity', 1.0)
  ).on('mouseout', (d, i) ->
    d3.select(this).
      transition().
      attr('stroke-width', 1).
      attr('opacity', 0.5)
  )

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

  $('svg circle').tipsy
    gravity: 'w'
    html: true
    title: -> @__data__.text

d3.json "/assets/tweets.json", draw
