Promise = require("bluebird")
RedisObserver = require("./redisObserver")

module.exports =
  class DeadLetterSucceeded extends RedisObserver

    success: (notification, reader) =>
      return Promise.resolve() unless reader.isReadingFromDeadLetter()
      @publish notification, success: true
