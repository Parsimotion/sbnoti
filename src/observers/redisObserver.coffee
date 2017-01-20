redis = require("../services/redis")
Promise = require("bluebird")

module.exports =
  class RedisObserver

    error: ->
    success: ->
    publish: (key, value) =>
      Promise.resolve()
      #redis.setAsync key, @buildValue value
    buildValue: (value) ->
      try
        JSON.stringify value
      catch
        value
