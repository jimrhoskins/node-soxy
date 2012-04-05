fs = require 'fs'
{reload} = require './util'
{Site} = require './site'


isObject = (x) ->
  x and typeof x is 'object' and x.constructor isnt Array

merge = (to, from) ->
  for key in Object.keys(to).concat(Object.keys(from))
    if key not of to
      to[key] = from[key]
    if key of to and key of from and isObject(to[key]) and isObject(from[key])
      merge(to[key], from[key])

class Config
  constructor: ->
    @bootstrap()
    @reload()

  reload: ->
    @sites = {}
    @soxyConfig = reload(require, @soxyConfigPath)
    @loadSites()

  # Configure core config based on env.NODE_ENV
  bootstrap: () ->
    switch process.env.NODE_ENV ? 'development'
      when 'development'
        @configPath = "#{__dirname}/../config"
        @logPath = "#{__dirname}/../log"

        @sitesPath = "#{@configPath}/sites"
        @soxyConfigPath = "#{@configPath}/soxy.json"

      else
        throw "Unkown Environment #{process.env.NODE_ENV}"

  loadSites: ->
    for file in fs.readdirSync(@sitesPath)
      path = "#{@sitesPath}/#{file}"
      continue unless file.match(/\.json$/i) and fs.statSync(path).isFile() 
      filename = file.replace(/\.json$/i, '')
      site = new Site(filename)
      site.read(@)
      @sites[site.filename] = site

exports.Config = Config

if require.main is module
  c = new Config
  console.log c
