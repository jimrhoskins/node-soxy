fs = require 'fs'

class HandlersManager
  constructor: (@env) ->
    @reload()

  reload: ->
    @loadHandlers()

  loadHandlers: ->
    @handlers = {}
    for file in fs.readdirSync("#{__dirname}/../handlers")
      handler = require("#{__dirname}/../handlers/#{file}")
      @handlers[handler.name] = handler


  getForSite: (site, server) ->
    # Load, config and return handler
    data = JSON.parse(site.serialize(true))
    handler = @handlers[data.type]
    return unless handler

    for own key, options of handler.options
      if options.required and not data[key]?
        throw new Error("required option #{key} not specified for #{data.name}")

      if options.default
        data[key] ?= options.default

    handler.builder(data, server)



module.exports.HandlersManager = HandlersManager
