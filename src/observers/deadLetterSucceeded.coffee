_ = require("lodash")
RedisObserver = require("./redisObserver")

module.exports =
  class DeadLetterSucceeded extends RedisObserver

    success: (notification, reader) =>
      if reader.isReadingFromDeadLetter()
        @publish notification, success: true
