class Router
  constructor: (@server) ->
    @loadHostTable()


  loadHostTable: ->
    @hosts = {}

    for site in @server.sites.all()
      handler = @server.handlers.getForSite(site, @server)
      if handler
        for host in site.hosts()
          @hosts[host] = handler
      else
        console.error 'Cannot find handler for ', site


  handlerForRequest: (req, type='request') ->
    [host] = req.headers.host.split(':')
    @hosts[host]?[type]



module.exports.Router = Router
