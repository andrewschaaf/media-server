
express = require 'express'

app = express.createServer express.logger()

app.set 'views', "#{__dirname}/../views"
app.set 'view engine', 'jade'
app.use express.bodyParser()
app.use app.router
app.use express.static "#{__dirname}/../public"
app.use express.errorHandler {dumpExceptions: true, showStack: true}

[PORT, HOST] = [6379, 'localhost']
app.redis = require('redis').createClient PORT, HOST, return_buffers:true

require('./app')(app)

port = process.env.PORT or 3000
app.listen port, () ->
  console.log "Listening on #{port}..."
