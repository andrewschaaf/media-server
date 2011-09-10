
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
      item.item_token = item_token
      res.render 'watch', locals:
        item: item
  
  #### Upload
  app.post '/api/upload', (req, res, next) ->
    item_token = randomToken 8
    file_token = randomToken 8
    
    r.hset "item_info:#{item_token}", 'created_at', JSON.stringify(new Date().getTime())
    r.hset "item_info:#{item_token}", 'file_token', JSON.stringify(file_token)
    r.lpush "item_tokens", item_token
    
    req.on 'data', (data) ->
      r.append "file_data:#{file_token}", data
    req.on 'end', () ->
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

