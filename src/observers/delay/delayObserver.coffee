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

    handle: (notification) =>
      delay = @_messageDelay notification.message
      return Promise.resolve() unless @_delayChanged delay
      @currentDelay = delay
      @publish notification, @currentDelay.name
      #Quiere dejar de decir delay!?!
      #https://www.youtube.com/watch?v=ZpNWkFWNhw0

    _messageDelay: (message) =>
      @_delayByMilliseconds @_millisecondsDelay message, new Date()

    _millisecondsDelay: ({ brokerProperties: { EnqueuedTimeUtc } }, now) =>
      enqueuedTime = moment new Date EnqueuedTimeUtc
      moment(now).diff enqueuedTime

    _delayChanged: (newDelay) => !_.isEqual newDelay, @currentDelay

    _delayByMilliseconds: (ms)=>
      __inRange = _.partial _.inRange, ms
      switch
        when __inRange mild.value then minimal
        when __inRange mild.value, moderate.value then mild
        when __inRange moderate.value, high.value then moderate
        when __inRange high.value, huge.value then high
        else huge

    _buildValue_ : _.identity
    _channelPrefix_: -> "health-queue"
