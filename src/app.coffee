livestream = require './livestream'


# Helper view functions
respond = (res, x) ->
  res.writeHead 200, {'Content-Type': 'text/javascript'}
  res.end JSON.stringify x

respondError = (res, message) ->
  res.writeHead 400, {'Content-Type': 'text/javascript'}
  res.end JSON.stringify {error: {message: message}}


module.exports = (app) ->
  # Index
  app.get '/', (req, res, next) ->
    lss = livestream.allLivestreams()
    res.render 'index', locals:
      'lss': lss


  # Get the playlist file for the stream
  app.get '/stream/:id/playlist.m3u8', (req,res,livestream_id) ->
    livestream_id = req.params.id

    # Get the object
    ls = livestream.getLivestream(livestream_id)

    # Create the current version of the playlis
    res.writeHead 200, {'Content-Type': 'application/x-mpegURL'}
    res.end ls.playlistText()

  # Return the page that is actually displaying the livestream
  app.get '/stream/:id/', (req,res) ->
    livestream_id = req.params.id

    # URL of the streaming playlist
    playlist_url = "/stream/#{livestream_id}/playlist.m3u8"

    # Render the page
    res.render 'stream',
      "livestream_id":livestream_id
      "playlist_url":playlist_url

  # Manual upload page for debugging
  app.get '/stream/:id/upload/', (req,res) ->
    res.render 'streamupload.jade'

