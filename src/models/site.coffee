fs = require 'fs'
{reload} = require '../util'
{JsonFile} = require './json_file'

class Site extends JsonFile
  type: -> @data.type
  hosts: -> @data.hosts?.split(/[\s,]+/)

  validate: ->
    @errors = []
    unless  @id().match(/^[-a-z0-9_\.]+$/i)
      @errors.push('filename must contain only letters, numbers, dots, dashes, and underscores')
    unless typeof @data.name is 'string' and @data.name.length >= 3
      @errors.push('name must be at least 3 characters')
    unless typeof @data.hosts is 'string'
      @errors.push('hosts must be a space separated list of hostnames')
    unless typeof @data.type is 'string'
      # TODO validate type
      @errors.push('must specify type')

    return @errors.length is 0


class SitesManager
  constructor: (@env) ->
    @sites = {}
    @reload()

  reload: ->
    @sites = {}
    @loadSitesFromDir(@env.sitesPath)

  all: ->
    (site for id, site of @sites)

  find: (id) ->
    @sites[id]

  loadSitesFromDir: (dir) ->
    for file in fs.readdirSync(dir)
      path = "#{dir}/#{file}"

      continue unless file.match(/\.json$/i) and fs.statSync(path).isFile() 

      filename = file.replace(/\.json$/i, '')
      site = new Site(path)
      site.read()
      @sites[site.id()] = site




exports.Site = Site
exports.SitesManager = SitesManager
