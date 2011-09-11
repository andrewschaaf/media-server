
fs = require 'fs'



slowPipe = (src, dest, opt) ->
  

parseRangeHeader = (range) ->
  # bytes=1261188-
  start = 0
  end = null
  if m = range.match /bytes=([0-9]+)-/
    start = parseInt(m[1], 10)
  {
    start: start
    end: end
  }


module.exports = (app) ->
  
  app.get '/exploration/html5', (req, res, next) ->
    res.writeHead 200, {'Content-Type': 'text/html'}
    res.end """
      <html>
        <head></head>
        <body>
          
          <video
            id="video"
            autoplay="true"
            controls>
            <source src="/exploration/video.mp4" type="video/mp4" />
          </video>
          
        </body>
      </html>
    """
  
  app.get '/exploration/video.mp4', (req, res, next) ->
    
    {range} = req.headers
    if range
      {start, end} = parseRangeHeader range
    
    res.writeHead 200, {'Content-Type': 'video/mp4'}
    file = fs.createReadStream "#{__dirname}/../test/files/talk.mp4"
    file.pipe res


# video.webkitEnterFullscreen

