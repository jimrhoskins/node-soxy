net = require 'net'
{EventEmitter} = require 'events'

class Watcher extends EventEmitter
  constructor: (@port) ->
    super
    @attempt()

  attempt: =>
    @client = net.connect(@port)
    @client.on 'error', (e) =>
      #@emit 'error', e
      if e.code is 'ECONNREFUSED'
        setTimeout =>
          @emit 'retry'
          @client.end()
          @attempt()
        , 1000

    @client.on 'connect',  =>
      @client.end()
      process.nextTick =>
        @emit 'connect'


watch = (port) ->
  w = new Watcher(port)

exports.onAvailable = (port, callback) ->
  (new Watcher(port)).on('connect', -> callback?()).on('retry', -> 
    console.log 'RETRY', port)

if require.main is module
  watch(7001).on 'connect', () ->
    console.log 'CONNECTED!'
  
