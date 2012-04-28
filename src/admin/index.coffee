express = require 'express'
{spawn} = require 'child_process'
less = require('connect-lesscss')

module.exports = (getServer) ->
  app = express.createServer()
  app.use express.bodyParser()
  io = require('socket.io').listen(app)

  app.configure ->
    app.set 'views', "#{__dirname}/views"
    app.use express.static("#{__dirname}/public")
    app.use "/admin.css", less("#{__dirname}/less/admin.less")
    app.use (req, res, next) ->
      req.server = getServer()
      next()

  app.get '/', (req, res) ->
    console.log req.server.apps
    res.render 'index.jade', 
      sites: req.server.sites.all()
      apps: req.server.apps.all()
      server: req.server
      serverStarted: require('moment')(req.server.startedAt).calendar()

  app.get '/sites/:id/edit', (req, res, next) ->
    site = req.server.sites.find(req.params.id)
    if site
      res.render 'edit.jade', site: site
    else
      next()

  app.post '/sites/:id', (req, res, next) ->
    site = req.server.sites.find(req.params.id)
    if site
      site.data = JSON.parse(req.body.content)
      site.write (err) ->
        return next(err) if err
        req.server.reload()
        res.redirect '/'
    else
      next()


  app.get '/log', (req, res) ->
    res.render 'log.jade'

  app.get '/reset', (req, res) ->
    req.server.reload()
    res.redirect('/')


  io.sockets.on 'connection', (socket) ->
    socket.on 'tail-log', ()->
      tail = spawn "tail", ["-f", getServer().logfile]
      tail.stdout.on 'data', (chunk) ->
        socket.emit 'log-data', chunk.toString()
      socket.on 'disconnect', ->
        tail.kill()

  return app
