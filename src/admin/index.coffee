express = require 'express'
{spawn} = require 'child_process'

module.exports = (getServer) ->
  app = express.createServer()
  app.use express.bodyParser()
  io = require('socket.io').listen(app)

  app.configure ->
    app.set 'views', "#{__dirname}/views"
    app.use express.static("#{__dirname}/public")

  app.get '/', (req, res) ->
    sites = getServer().sites
    res.render 'index.jade', 
      sites: sites
      server: getServer()
      serverStarted: require('moment')(getServer().startedAt).calendar()

  app.get '/sites/:id/edit', (req, res, next) ->
    site = getServer().sites[req.params.id]
    if site
      res.render 'edit.jade', site: site
    else
      next()

  app.post '/sites/:id', (req, res, next) ->
    site = getServer().sites[req.params.id]
    if site
      site.content = JSON.parse(req.body.content)
      site.save getServer().config, (err) ->
        getServer().reload()
        res.redirect '/'
    else
      next()


  app.get '/log', (req, res) ->
    res.render 'log.jade'

  app.get '/reset', (req, res) ->
    getServer().reload()
    res.redirect('/')


  io.sockets.on 'connection', (socket) ->
    socket.on 'tail-log', ()->
      tail = spawn "tail", ["-f", getServer().logfile]
      tail.stdout.on 'data', (chunk) ->
        socket.emit 'log-data', chunk.toString()
      socket.on 'disconnect', ->
        tail.kill()

  return app
