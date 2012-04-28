# Name of handler (matches "type" property of site-config)
exports.name = "foreman"

# Description of handler, for documentation
exports.description = "Run a foreman file and proxy the server"

# Options accepted in site-config
exports.options = 
  root:
    description: "The root of the target application"
    require: true



{ForemanApp} = require '../process'
httpProxy = require('http-proxy')

# Handler builder, passed site-config, returns connect handler
exports.builder = (config, server) ->
  PORT = server.apps.requestPort()

  app = new ForemanApp
    cwd: config.root
    port: PORT

  server.apps.register app

  proxy = new httpProxy.HttpProxy(
    target: 
      host: '127.0.0.1'
      port: app.port
  )

  proxy.on 'proxyError', (err, req, res) ->
    app.ensureRunning ->
      proxy.proxyRequest req, res, req.buffer
    return true

  connect = require 'connect'

  request = (req, res, next) ->
    req.buffer = httpProxy.buffer(req)
    proxy.proxyRequest(req, res)

  upgrade = (req, socket, head) ->
    req.buffer = httpProxy.buffer(req)
    proxy.proxyWebSocketRequest(req, socket, head)

  return {
    request
    upgrade
  }


