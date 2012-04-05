# require without cache
exports.reload = (req, mod) ->
  delete req.cache[req.resolve(mod)]
  req(mod)
