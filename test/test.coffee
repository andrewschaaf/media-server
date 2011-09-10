
fs = require 'fs'
http = require 'http'
assert = require 'assert'
{readData} = require 'tafa-misc-util'

assertEqual = (x, y) ->
  if x instanceof Buffer and y instanceof Buffer
    x64 = x.toString('base64')
    y64 = y.toString('base64')
    if x64 != y64
      if x.length != y.length
        console.log "**** lengths: #{x.length}, #{y.length}"
      else
        console.log '(same lengths)'
    assert.equal x.toString('base64'), y.toString('base64')
  else
    assert.equal x, y


read = (filename) ->
  path = "#{__dirname}/files/#{filename}"
  fs.readFileSync path


request = ({path,method,data}, callback) ->
  method or= 'GET'
  opt = {
    host: 'localhost'
    port: 3000
    path: path
    method: method
  }
  req = http.request opt, (res) ->
    
    readData res, (data) ->
      
      if res.headers['content-type'] == 'text/javascript'
        payload = JSON.parse data.toString 'utf-8'
      else
        payload = data
      
      if res.statusCode != 200
        throw new Error "#{res.statusCode}: #{data.toString('utf-8')}"
      
      callback payload
  
  req.on 'error', (e) ->
    throw e
  if data
    req.end data
  else
    req.end()


upload_file = (filename, callback) ->
  request {
    method: 'POST'
    path:'/api/upload-file'
    data: read(filename)
  }, callback


get_file = (file_token, callback) ->
  request {
    method: 'GET'
    path: "/api/get-file?file_token=#{file_token}"
  }, callback


main = () ->
  request path:'/api/reset', () ->
    upload_file "textmate.mov", ({file_token}) ->
      get_file file_token, (data) ->
        assertEqual read("textmate.mov"), data
        console.log 'OK'


#noisyExec "ruby test/selenium-tests.rb", (e, out, err) ->
#  throw e if e



module.exports =
  main: main
