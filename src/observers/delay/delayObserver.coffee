{ minimal, mild, moderate, high, huge } = require("./delays")
RedisObserver = require("../redisObserver")
moment = require("moment")

module.exports =

  new class DelayObserver extends RedisObserver

    constructor: ->
      @currentDelay = minimal

    handle: (notification) =>
      delay = @_messageDelay notification.message

      if @_delayChanged delay
        @currentDelay = delay
        @publish notification, @currentDelay.name
      #Quiere dejar de decir delay!?!
      #https://www.youtube.com/watch?v=ZpNWkFWNhw0

    _messageDelay: (message) =>
      @_delayByMilliseconds @_millisecondsDelay message

    _millisecondsDelay: ({ brokerProperties: { EnqueuedTimeUtc } }) =>
      enqueuedTime = moment new Date EnqueuedTimeUtc
      moment().diff enqueuedTime

    _delayChanged: (newDelay) => !_.isEqual newDelay, @currentDelay

    _delayByMilliseconds: (ms)=>
      __inRange = _.partial _.inRange, ms
      switch
        when __inRange minimal.value, mild.value then minimal
        when __inRange mild.value, moderate.value then mild
        when __inRange moderate.value, high.value then moderate
        when __inRange high.value, huge.value then high
        else huge


    _channelPrefix_: -> "health-queue"
