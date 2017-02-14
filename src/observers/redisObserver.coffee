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
      @redis.publishAsync @_getChannel(notification), @_buildValue_ value, notification

    _buildValue_: (value, notification) ->
      try
        JSON.stringify value
      catch
        value

    _getChannel: ({ message: { brokerProperties: { MessageId }, body }, app, topic, subscription }) =>
        parsedBody = JSON.parse body
        { CompanyId, ResourceId } = parsedBody
        "#{@_channelPrefix_()}/#{app}/#{CompanyId}/#{topic}/#{subscription}/#{ResourceId}"

    _channelPrefix_: -> "health-message-sb"
