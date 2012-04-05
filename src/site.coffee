fs = require 'fs'
{reload} = require './util'
class Site
  constructor: (filename, content) ->
    @filename = filename
    @content = content

  type: -> @content.type
  hosts: -> @content.hosts?.split(/[\s,]+/)

  read: (config) ->
    filepath = "#{config.sitesPath}/#{@filename}.json"
    @content = reload(require, filepath)

  save: (config, callback) ->
    unless @validate()
      return callback(@errors)
    filepath = "#{config.sitesPath}/#{@filename}.json"
    contents = JSON.stringify(@content, null, 2)
    fs.writeFile filepath, contents, (err) ->
      callback(err)

  validate: ->
    @errors = []
    unless  @filename.match(/^[-a-z0-9_\.]+$/i)
      @errors.push('filename must contain only letters, numbers, dots, dashes, and underscores')
    unless typeof @content.name is 'string' and @content.name.length > 3
      @errors.push('name must be at least 3 characters')
    unless typeof @content.hosts is 'string'
      @errors.push('hosts must be a space separated list of hostnames')
    unless typeof @content.type is 'string'
      # TODO validate type
      @errors.push('must specify type')

    return @errors.length is 0

exports.Site = Site
