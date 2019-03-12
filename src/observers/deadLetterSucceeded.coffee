Promise = require("bluebird")
RedisObserver = require("./redisObserver")

module.exports =
  class DeadLetterSucceeded extends RedisObserver

    success: (notification) =>
      @publish notification, success: true

    appliesToFailed: -> true
    appliesToPending: -> false
