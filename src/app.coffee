
url = require 'url'
crypto = require 'crypto'
stitch = require 'stitch'
{randomToken, timeoutSet} = require 'tafa-misc-util'
livestream = require './livestream'



respond = (res, x) ->
  res.writeHead 200, {'Content-Type': 'text/javascript'}
  res.end JSON.stringify x


respondError = (res, message) ->
  res.writeHead 400, {'Content-Type': 'text/javascript'}
  res.end JSON.stringify {error: {message: message}}


module.exports = (app) ->
  r = app.redis
  
  search = (callback) ->
    r.lrange "item_tokens", 0, -1, (e, arr) ->
      itemTokens = (x.toString() for x in arr)
      items = ({item_token: item_token} for item_token in itemTokens)
      callback null, {
        items: items
      }
  
  getInfo = (k, callback) ->
    r.hgetall k, (e, infoBufs) ->
      info = {}
      for own k, v of infoBufs
        info[k] = JSON.parse v.toString('utf-8')
      callback null, info
  
  #### client.js
  app.get '/client.js', (req, res, next) ->
    package = stitch.createPackage {
      paths: ["#{__dirname}/client"]
    }
    package.compile (e, js) ->
      res.writeHead 200, {'Content-Type': 'text/javascript'}
      res.end new Buffer js, 'utf-8'
  
  #### Index
  app.get '/', (req, res, next) ->
    search (e, results) ->
      {items} = results
      res.render 'index', locals:
        items: items
  
  #### Watch
  app.get '/watch', (req, res, next) ->
    {v} = url.parse(req.url, true).query
    item_token = v
    getInfo "item_info:#{item_token}", (e, item) ->
      js = """
        item_token = #{JSON.stringify item_token};
        file_token = #{JSON.stringify item.file_token};
      """
      item.item_token = item_token
      r.get "file_data:#{item.file_token}", (e, data) ->
        item.sha1 = crypto.createHash('sha1').update(data).digest('hex')
        res.render 'watch', locals:
          item: item
          js: js
  
  #### File
  app.get '/file.mov', (req, res, next) ->
    
    {file_token} = url.parse(req.url, true).query
    
    {range} = req.headers
    if range
      throw new Error ('****** RANGE: ' + JSON.stringify(range))
    
    r.get "file_data:#{file_token}", (e, data) ->
      # data = require('fs').readFileSync "/Users/a/Desktop/media-server/test/files/textmate.mov"
      res.writeHead 200, {'Content-Type': 'video/quicktime'}
      res.end data
  
  #### Upload
  app.post '/api/upload', (req, res, next) ->
    item_token = randomToken 8
    file_token = randomToken 8
    
    r.hset "item_info:#{item_token}", 'created_at', JSON.stringify(new Date().getTime())
    r.hset "item_info:#{item_token}", 'file_token', JSON.stringify(file_token)
    r.lpush "item_tokens", item_token
    
    req.on 'data', (data) ->
      console.log "[UPLOAD] got #{data.length} more bytes"
      r.append "file_data:#{file_token}", data
    req.on 'end', () ->
      console.log "[UPLOAD] DONE"
      timeoutSet 500, () -> #TODO: respond only after all data saved
        r.hset "item_info:#{item_token}", 'completed_at', JSON.stringify(new Date().getTime()), (e, v) ->
          respond res, {
            item_token: item_token
            file_token: file_token
          }
  
  #### Get file
  app.get '/api/get-file', (req, res, next) ->
    {file_token} = url.parse(req.url, true).query
    if not file_token
      return respondError res, "You need to specify file_token"
    r.get "file_data:#{file_token}", (e, data) ->
      console.log (data instanceof Buffer)
      res.writeHead 200, {}
      res.end data
  
  #### Search
  app.get '/api/search', (req, res, next) ->
    search (e, results) ->
      respond res, results
  
  #### TEMP
  app.get '/api/reset', (req, res, next) ->
    r.flushdb () ->
      console.log '**** Redis flushed ****'
      respond res, {}


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


  app.get '/teststreaming', (req,res) ->
      res.render 'teststreaming'



