{ minimal, mild, moderate, high, huge } = require("./delays")
RedisObserver = require("../redisObserver")
moment = require("moment")

module.exports =

  new class DelayObserver extends RedisObserver

    constructor: ->
      @currentDelay = Minimal

    handle: (notification) =>
      milliseconds = @_millisecondsDelay notification
      @publish notification, milliseconds if @_delayChanged notification, milliseconds

    _millisecondsDelay: ({ message }) =>
      enqueuedTime = moment new Date message.brokerProperties.EnqueuedTimeUtc
      enqueuedTime.diff(moment())

    _delayChanged: (notification, millisecondsDelay) =>
      newDelay = _delayByMilliseconds millisecondsDelay
      !_.isEqual newDelay, @currentDelay

    _delayByMilliseconds: (ms)=>
      __inRange = _.partial _.inRange, ms
      switch
        when __inRange minimal.value, mild.value then minimal
        when __inRange mild.value, moderate.value then mild
        when __inRange moderate.value, high.value then moderate
        when __inRange high.value, huge.value then high
        else huge


    _channelPrefix_: -> "health-queue"
