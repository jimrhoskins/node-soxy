{reload} = require '../util'
fs = require 'fs'
_path = require 'path'

class JsonFile
  constructor: (@path, @data) ->

  id: -> @basename(true)

  read: ->
    @data = reload(require, @path)

  write: (cb) ->
    unless @validate() 
      return cb(@errors)
    fs.writeFile @path, @serialize(), cb

  serialize: (minify=false) ->
    indent = if minify then 0 else 2
    JSON.stringify @data, null, indent


  basename: (removeExtension) ->
    _path.basename(@path, removeExtension and '.json')

  validate: -> 
    @errors = []
    true

  dirname: -> _path.dirname(@path)
  extname: -> _path.extname(@path)


exports.JsonFile = JsonFile
