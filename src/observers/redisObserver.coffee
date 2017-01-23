Redis = require("../services/redis")
Promise = require("bluebird")

module.exports =
  class RedisObserver
    constructor: (redisConfig) ->
      @redis = Redis.createClient redisConfig.port, redisConfig.host, db: redisConfig.db
      @redis.auth redisConfig.auth if redisConfig.auth

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
      console.log "_getChannel", "health-message/#{app}/#{CompanyId}/#{topic}/#{subscription}/#{ResourceId}"
      "health-message/#{app}/#{CompanyId}/#{topic}/#{subscription}/#{ResourceId}"

