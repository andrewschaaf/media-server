
url = require 'url'
{randomToken, timeoutSet} = require 'tafa-misc-util'



respond = (res, x) ->
  res.writeHead 200, {'Content-Type': 'text/javascript'}
  res.end JSON.stringify x


respondError = (res, message) ->
  res.writeHead 400, {'Content-Type': 'text/javascript'}
  res.end JSON.stringify {error: {message: message}}


module.exports = (app) ->
  r = app.redis
  
  app.get '/', (req, res, next) ->
    res.render 'index'
  
  app.post '/api/create-item', (req, res, next) ->
    item_token = randomToken 8
    respond res, {
      item_token: item_token
    }
  
  app.post '/api/upload-file', (req, res, next) ->
    file_token = randomToken 8
    req.on 'data', (data) ->
      r.append "file_data:#{file_token}", data
    req.on 'end', () ->
      #TODO: respond only after all data saved
      timeoutSet 500, () ->
        respond res, {
          file_token: file_token
        }
  
  app.get '/api/get-file', (req, res, next) ->
    {file_token} = url.parse(req.url, true).query
    
    if not file_token
      return respondError res, "You need to specify file_token"
    
    console.log 'req.url', req.url
    console.log "file_token: ", file_token
    r.get "file_data:#{file_token}", (e, data) ->
      console.log (data instanceof Buffer)
      res.writeHead 200, {}
      res.end data
  
  # TODO
  app.get '/api/reset', (req, res, next) ->
    r.flushdb () ->
      console.log '**** Redis flushed ****'
      respond res, {}

