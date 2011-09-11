http = require 'http'
fs = require 'fs'
livestream = require './livestream'


# Helper view functions
respond = (res, x) ->
  res.writeHead 200, {'Content-Type': 'text/javascript'}
  res.end JSON.stringify x

respondError = (res, message) ->
  res.writeHead 400, {'Content-Type': 'text/javascript'}
  res.end JSON.stringify {error: {message: message}}


sendFileToSegmenter = (path,callback) ->
  post_options = 
    host: 'localhost'
    port: '3000'
    path: '/testpost'
    method: 'POST'


  console.log "sending file at path #{path}"
  post_request = http.request post_options, (res) ->
    if callback? then callback()

  # Pipe file into the post request
  fs.createReadStream(path).pipe post_request


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

  app.post '/stream/:id/upload/', (req,res) ->
    # Get the livestream
    livestream_id = req.params.id
    ls = livestream.getLivestream(livestream_id)

    req.form.complete (err,fields,files) ->
      if err
        res.end err
      else
        # Forward along the file to the segmenter app
        sendFileToSegmenter files.segment.path, ->
          res.end "ok"

  app.post '/internal/add_segment', (req,res) ->
    stream_id = req.param('stream')
    if not stream_id?
      throw Error("No stream id given to internal add segment")

    ls = livestream.getLivestream(stream_id)

    # Find out where it should go
    destdir = "#{__dirname}/../public/segmented/"
    filename = "#{stream_id}-#{Math.floor(Math.random()*1000000)}"
    dest = destdir + filename

    # Write out the file
    console.log 'pipe'
    console.log 'endpipe'
    console.log dest
    f = fs.createWriteStream dest
    f.on 'close', ->
      console.log "Wrote file #{dest}"

      # Add link to the live stream
      url = "/segmented/#{filename}"
      ls.addTs url

      # Close the stream
      res.end 'ok'


    # Write out file
    req.pipe(f)

