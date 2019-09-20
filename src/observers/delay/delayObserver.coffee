_ = require("lodash")
moment = require("moment")
Promise = require("bluebird")
RedisObserver = require("../redisObserver")
{ minimal, mild, moderate, high, huge } = require("./delayLevels")

module.exports =

  class DelayObserver extends RedisObserver

    constructor: (redis) ->
      super redis
      @currentDelay = minimal

    finish: (notification) =>
      delay = @_messageDelay notification.message
      return Promise.resolve() unless delay? and @_delayChanged delay
      @currentDelay = delay
      @publish notification, @currentDelay.name
      #Quiere dejar de decir delay!?!
      #https://www.youtube.com/watch?v=ZpNWkFWNhw0

    _messageDelay: (message) =>
      @_delayByMilliseconds @_millisecondsDelay message, new Date()

    _millisecondsDelay: ({ enqueuedTimeUtc }, now) =>
      enqueuedTime = moment.utc new Date enqueuedTimeUtc
      moment.utc(now).diff enqueuedTime

    _delayChanged: (newDelay) => !_.isEqual newDelay, @currentDelay

    _delayByMilliseconds: (ms)=>
      delayLeves = [ minimal, mild, moderate, high, huge ]
      _.findLast delayLeves, ({value}) => ms >= value

    _buildValue_ : _.identity

    _channelPrefix_: -> "health-delay-sb"

    _getChannel: ({ app, topic, subscription }) =>
      "#{@_channelPrefix_()}/#{app}/#{topic}/#{subscription}"

    appliesToFailed: -> true
    appliesToPending: -> true
