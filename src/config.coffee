fs = require 'fs'
{reload} = require './util'
{Site} = require './models/site'


isObject = (x) ->
  x and typeof x is 'object' and x.constructor isnt Array

merge = (to, from) ->
  for key in Object.keys(to).concat(Object.keys(from))
    if key not of to
      to[key] = from[key]
    if key of to and key of from and isObject(to[key]) and isObject(from[key])
      merge(to[key], from[key])

class Config
  constructor: (@env)->
    @reload()

  reload: ->
    @soxy = reload(require, @env.soxyConfigPath)

exports.Config = Config

if require.main is module
  c = new Config
  console.log c
