Redis = require("../services/redis")
Promise = require("bluebird")

module.exports =
  class RedisObserver
    constructor: (@reader) ->
      config = @reader.config.health or {}
      @redis = Redis.createClient config.redis.port, config.redis.host, db: config.redis.db
      @redis.auth config.redis.auth if config.redis.auth

    error: ->

    success: ->

    publish: (message, value) =>
      @redis.publishAsync @_getChannel(message), @_buildValue value

    _buildValue: (value) ->
      try
        JSON.stringify value
      catch
        value

    _getChannel: ({ brokerProperties: { MessageId }, body }) =>
      { CompanyId, ResourceId } = body
      { app, topic, subscription } = @reader.config
      "health-message/#{app}/#{CompanyId}/#{topic}/#{subscription}/#{ResourceId}"

