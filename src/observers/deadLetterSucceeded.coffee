RedisObserver = require("./redisObserver")

module.exports =
  class DeadLetterSucceeded extends RedisObserver

    success: (notification, reader) =>
      if reader.isReadingFromDeadLetter()
        _.assign notification,
          subscription: notification.subscription.replace reader.deadLetterSuffix, ''
        @publish notification, success: true
