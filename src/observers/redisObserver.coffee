Redis = require("../services/redis")
Promise = require("bluebird")

module.exports =
  class RedisObserver
    constructor: (config = { redis: { } }) ->
      @redis = Redis.createClient config.redis.port, config.redis.host, db: config.redis.db
      @redis.auth config.redis.auth if config.redis.auth

    error: ->
    success: ->
    publish: (key, value) =>
      @redis.publishAsync key, @_buildValue value

    _buildValue: (value) ->
      try
        JSON.stringify value
      catch
        value
