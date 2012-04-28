{EventEmitter} = require 'events'
{spawn} = require 'child_process'
port = require './port'

class AppsManager
  constructor: ->
    @nextPort = 11000
    @nextId = 0
    @apps = {} 

  reload: ->
    for app in @all
      app?.stop?()
    @apps = {}

  register: (process) ->
    id = @requestId()
    @apps[id] = process
    process.id = id
    process

  all: ->
    (app for own id, app of @apps)


  find: (id) ->
    @apps[id]

  requestPort: ->
    @nextPort += 1

  requestId: ->
    @nextId += 1


class App extends EventEmitter
  
  start: ->
    @process = spawn @command, @args, {
      cwd: @cwd ? undefined
      env: @env ? process.env
    }

    @running = true

    @emit 'start', @process

    @process.stdout.on 'data', (data) =>
      @emit 'stdout', data

    @process.stderr.on 'data', (data) =>
      @emit 'stderr', data

    @process.on 'exit', ->
      @running = false
      @emit 'exit'

    @timeoutTimer = setTimeout =>
      @stop()
    , @timeout * 1000 if @timeout

  stdin: (data) ->
    @process?.stdin?.write?(data)

  stop: ->
    @kill()

  kill: (args...) ->
    @process?.kill?(args...)


class ForemanApp extends App
  constructor: (options = {}) ->
    @port = options.port if options.port?
    @concurrency = options.port if options.concurrency?
    @cwd = options.cwd if options.cwd?


  start: ->
    @command = '/home/jhoskins/.rbenv/shims/foreman'
    @args = ['start']
    @args.push "--port=#{@port}" if @port
    @args.push "--concurrency=\"#{@concurrency}\"" if @concurrency
    super()

  ensureRunning: (cb) ->
    @start() 
    port.onAvailable @port, cb

  description: ->
    """Foreman app #{"not" unless @running}running on #{@port} with id #{@id}"""


module.exports.ForemanApp = ForemanApp
module.exports.AppsManager = AppsManager


if require.main is module
  s = new Foreman
    cwd: "/home/jhoskins/dev/videos"
    port: 7722
  s.on 'stdout', (x) -> console.log x.toString()
  s.on 'stderr', (x) -> console.log x.toString()
  s.run()


