RedisObserver = require("./redisObserver")

module.exports =
  class DeadLetterSucceeded extends RedisObserver

    success: (message) =>
      if @reader.isReadingFromDeadLetter()
        @publish message, success: true
