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

    _buildValue_: (value, notification) -> JSON.stringify value

    _getChannel: ({ message: { brokerProperties: { MessageId }, body }, app, topic, subscription }) =>
      { CompanyId, ResourceId } = body
      "#{@_channelPrefix_()}/#{app}/#{CompanyId}/#{topic}/#{subscription}/#{ResourceId}"

    _channelPrefix_: -> "health-message-sb"
