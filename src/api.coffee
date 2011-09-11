http = require 'http'
fs = require 'fs'
livestream = require './livestream'
options = require './options'


# Helper view functions
respond = (res, x) ->
  res.writeHead 200, {'Content-Type': 'text/javascript'}
  res.end JSON.stringify x

respondError = (res, message) ->
  res.writeHead 400, {'Content-Type': 'text/javascript'}
  res.end JSON.stringify {error: {message: message}}


# Given a file stream of the video piece, sends it off to the segmenter service
# to be broken up and returned in pieces
sendFileToSegmenter = (stream,stream_id, callback) ->
  callback_url = "http://#{options.THIS_HOSTNAME}:#{options.THIS_PORT}/internal/add_segment?stream=#{stream_id}"
  post_options = 
    host: options.SEGMENTER_HOSTNAME
    port: options.SEGMENTER_PORT
    path: "/segment_ts/?callback_url=#{encodeURIComponent(callback_url)}"
    method: 'POST'

  console.log "sending file to segment service:"
  console.log post_options
  post_request = http.request post_options, (res) ->
    if callback? then callback()

  # Pipe file into the post request
  stream.pipe post_request


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

    # Use the stream of the body data to send to the segmenter service
    sendFileToSegmenter req, req.params.id, ->
      res.end "ok"

  app.post '/internal/add_segment', (req,res) ->
    stream_id = req.param('stream')
    if not stream_id?
      throw Error("No stream id given to internal add segment")

    ls = livestream.getLivestream(stream_id)

    # Find out where it should go
    destdir = "#{__dirname}/../public/segmented/"
    filename = "#{stream_id}-#{Math.floor(Math.random()*1000000)}.ts"
    dest = destdir + filename
    url = "/segmented/#{filename}"

    # Write out the file
    console.log 'add_segment writing out file'
    f = fs.createWriteStream dest
    f.on 'close', ->
      console.log "Wrote file #{dest}"

      # Add link to the live stream
      ls.addTs url

      # Close the request
      res.end 'ok'


    # Write out file
    console.log "Writing to #{dest}"
    req.pipe(f)

  # DEBUG: A pretend segment handler that just takes the file and passes it through
  app.post '/segment_ts/', (req,res) ->
    console.log "got post request with callback: #{req.param('callback_url')}"

    post_options = 
      host: 'localhost'
      port: options.THIS_PORT
      path: req.param('callback_url')
      method: 'POST'

    console.log "PRETEND SEGMENTER: Sending file to /internal/add_segment"
    console.log post_options
    post_request = http.request post_options, (this_res) ->
      console.log "PRETEND SEGMENTER: file sent"
      res.end()

    # Pipe file into the post request
    req.pipe post_request

