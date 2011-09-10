
{noisyExec} = require 'tafa-misc-util'


task 'dev', () ->
  noisyExec "coffee -cwo lib src"
  noisyExec "stylus -c -w public"
  noisyExec "hotnode lib/server.js"


task 'test', () ->
  noisyExec "ruby test/selenium-tests.rb", (e, out, err) ->
    throw e if e
