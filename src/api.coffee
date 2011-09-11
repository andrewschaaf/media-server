livestream = require './livestream'


# Helper view functions
respond = (res, x) ->
  res.writeHead 200, {'Content-Type': 'text/javascript'}
  res.end JSON.stringify x

respondError = (res, message) ->
  res.writeHead 400, {'Content-Type': 'text/javascript'}
  res.end JSON.stringify {error: {message: message}}


module.exports = (app) ->
  # Return all the TSs in the stream
  app.get '/stream/:id/segments/', (req, res) ->
    livestream_id = req.params.id
    ls = livestream.getLivestream(livestream_id)

    # Make up response
    obj =
      id:livestream_id
      urls:ls.getTss()

    return respond(res,obj)

  # Add a TS URL to the stream
  app.get '/stream/:id/segments/add', (req, res) ->
    # Get the livestream
    livestream_id = req.params.id
    ls = livestream.getLivestream(livestream_id)

    # Get the url
    ts_url = req.param('url')
    if not ts_url? or ts_url.length == 0
      return respondError(res,"No 'url' param given")

    # Add the url to the next chunk to the stream playlist
    ls.addTs(ts_url)

    return respond(res,{'result':'ok'})
