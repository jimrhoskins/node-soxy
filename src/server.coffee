fs = require 'fs'
connect = require 'connect'
{Config} = require './config'

class Server
  constructor: ->
    @reload()

  reload: ->
    @handlers = {}
    @hosts = {}
    @config = new Config()
    @sites = @config.sites
    @logfile = "#{@config.logPath}/soxy.log"

    @loadHandlers()
    @loadSites()

    @stop =>
      @listen(@config.soxyConfig.port)
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
      handler = @getHandler(req)
      if handler
        handler(req, res, next) 
      else
        next()

    @server.on 'upgrade', (req, socket, head) =>
      upgrade = @getHandler(req, 'upgrade')
      upgrade?(req, socket, head)

    @httpServer = @server.listen(args...)
    @startedAt = new Date

  getHandler: (req, type='request') ->
    [host] = req.headers.host.split ':'
    @hosts[host]?[type]

  loadHandlers: ->
    for file in fs.readdirSync("#{__dirname}/handlers")
      handler = require("#{__dirname}/handlers/#{file}")
      @handlers[handler.name] = handler

  loadSites: ->
    for _, site of @config.sites
      handler = @handlers[site.type()]
      for host in site.hosts()
        @hosts[host] = getBuilder(handler,site)


getBuilder = (handler, site) ->
  data = Object.create(site.content)
  for own key, options of handler.options
    if options.required and not data[key]?
      throw new Error("required option #{key} not specified for #{data.name}")

    if options.default
      data[key] ?= options.default

  handler.builder(data)

if require.main is module
  s = new Server

  admin = require('./admin')(-> s)
  admin.listen(7002)

