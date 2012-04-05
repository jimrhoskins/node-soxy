DEFAULT_ENV = 'development'

module.exports = env = {}

switch process.env.NODE_ENV ? DEFAULT_ENV
  when 'development'
    env.configPath = "#{__dirname}/../config"
    env.logPath    = "#{__dirname}/../log"

    env.sitesPath  = "#{env.configPath}/sites"
    env.soxyConfigPath = "#{env.configPath}/soxy.json"

  else
    throw "Unkown Environment #{process.env.NODE_ENV}"
