draw = (tweets) ->
  d3.select('body').
     append('svg').
     selectAll('circle').
     data(tweets).
     enter().
     append('circle')

  d3.selectAll('circle').
     attr('cx', (d) ->
      date = new Date(d.created_at)
      date.getUTCHours() * 20
     ).
     attr('cy', (d) ->
      date = new Date(d.created_at)
      20 + date.getUTCDay() * 50
     ).
     attr('r', 15)

d3.json "/assets/tweets.json", draw

