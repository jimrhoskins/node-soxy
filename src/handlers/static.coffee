# Name of handler (matches "type" property of site-config)
exports.name = "static"

# Description of handler, for documentation
exports.description = "Serve static files from a directory"

# Options accepted in site-config
exports.options = 
  documentRoot:
    description: 'The root directory files will be served from'
    required: true
  maxAge:
    description: 'Browser cache maxAge in milliseconds.'
    default: 0
  hidden:
    description: 'Allow transfer of hidden files.'
    default: false
  redirect:
    description: 'Redirect to trailing "/" when the pathname is a dir'
    default: false
  index:
    description: 'Serve directory listings'
    default: false
  indexIcons:
    description: 'Show icons in directory indexes (requires index:true)'
    default: true
  indexHidden:
    description: 'Display hidden files in directory indexes (requires index:true)'
    default: false





# Handler builder, passed site-config, returns connect handler
exports.builder = (config) ->
  connect = require 'connect'

  handler = connect()

  handler.use(connect.static(config.documentRoot, {
    maxAge: config.maxAge
    redirect: config.redirect
    hidden: config.hidden
  }))

  if config.index
    handler.use(connect.directory(config.documentRoot, {
      icons: config.indexIcons
      hidden: config.indexHidden
    }))

  return {
    request: (args...) -> handler.handle(args...)
  }


