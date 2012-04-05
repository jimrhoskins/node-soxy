# Name of handler (matches "type" property of site-config)
exports.name = "proxy"

# Description of handler, for documentation
exports.description = "Simple forward/reverse proxy to host:port"

# Options accepted in site-config
exports.options = 
  target_host:
    default: 'localhost'
  target_port:
    required: true


# Handler builder, passed site-config, returns connect handler
exports.builder = (config) ->

  proxy = new (require('http-proxy').HttpProxy)(
    target:
      host: config.target_host
      port: config.target_port
  )

  request = (req, res, next) ->
    proxy.proxyRequest(req, res)

  upgrade = (req, socket, head) ->
    proxy.proxyWebSocketRequest(req, socket, head)

  return {
    request
    upgrade
  }

