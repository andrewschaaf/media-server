express = require 'express'

# Create app
app = express.createServer express.logger()

# Config
app.set 'views', "#{__dirname}/../views"
app.set 'view engine', 'jade'

# Middleware
app.use express.bodyParser()
app.use app.router
app.use express.static "#{__dirname}/../public"
app.use express.errorHandler {dumpExceptions: true, showStack: true}


# Main app code
require('./app')(app)
require('./api')(app)

# Kick it off
port = process.env.PORT or 3000
app.listen port, () ->
  console.log "Listening on #{port}..."
