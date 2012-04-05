class Router
  constructor: (@sites, @handlers) ->
    @loadHostTable()


  loadHostTable: ->
    @hosts = {}

    for site in @sites.all()
      handler = @handlers.getForSite(site)
      if handler
        for host in site.hosts()
          @hosts[host] = handler
      else
        console.error 'Cannot find handler for ', site


  handlerForRequest: (req, type='request') ->
    [host] = req.headers.host.split(':')
    @hosts[host]?[type]



module.exports.Router = Router
