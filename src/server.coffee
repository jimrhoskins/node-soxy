fs = require 'fs'
connect = require 'connect'
{Config} = require './config'
{SitesManager} = require './models/site'
{HandlersManager} = require './models/handler'
{AppsManager} = require './process'
{Router} = require './router'

class Server
  constructor: ->
    @env = require('./environment')
    @config = new Config(@env)
    @sites = new SitesManager(@env)
    @handlers = new HandlersManager(@env)
    @apps = new AppsManager
    @reload()

  reload: ->
    @sites.reload()
    @handlers.reload()
    @router = new Router(@)
    @logfile = "#{@env.logPath}/soxy.log"


    @stop =>
      @listen(@config.soxy.port)
      console.log 'RELOADED'

  stop: (cb) ->
    try
      @httpServer.on 'close', cb
      @httpServer.close()
    catch e
      cb()

  listen: (args...) ->
    @server = connect()

    @server.use connect.logger(stream: fs.createWriteStream(@logfile, flags: 'a'))

    @server.use (req, res, next) =>
      handler = @router.handlerForRequest(req, 'request')
      if handler
        handler(req, res) 
      else
        next()

    @server.on 'upgrade', (req, socket, head) =>
      upgrade = @router.handlerForRequest(req, 'upgrade')
      upgrade?(req, socket, head)

    @httpServer = @server.listen(args...)
    @httpServer.on 'error', (e) =>
      if e.code is 'EADDRINUSE'
        console.log 'Address in use, retrying...'
        setTimeout =>
          @httpServer.close()
          @httpServer.listen(args...)


if require.main is module
  s = new Server

  admin = require('./admin')(-> s)
  admin.listen(7002)

