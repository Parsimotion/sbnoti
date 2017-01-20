Redis = require("../services/redis")
Promise = require("bluebird")

module.exports =
  class RedisObserver
    constructor: (readerConfig) ->
      config = readerConfig.health or {}
      @verifyRedisConfig config.redis
      @redis = Redis.createClient config.redis.port, config.redis.host, db: config.redis.db
      @redis.auth config.redis.auth if config.redis.auth

    verifyRedisConfig: (config) =>
      throw new Error("redis_not_configured") unless config?.port? and config?.username? and config?.db?

    error: ->

    success: ->

    publish: (notification, value) =>
      @redis.publishAsync @_getChannel(notification), @_buildValue value

    _buildValue: (value) ->
      try
        JSON.stringify value
      catch
        value

    _getChannel: ({ message: { brokerProperties: { MessageId }, body }, app, topic, subscription }) =>
      { CompanyId, ResourceId } = body
      "health-message/#{app}/#{CompanyId}/#{topic}/#{subscription}/#{ResourceId}"

