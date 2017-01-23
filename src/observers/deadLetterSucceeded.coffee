_ = require("lodash")
RedisObserver = require("./redisObserver")

module.exports =
  class DeadLetterSucceeded extends RedisObserver

    success: (notification, reader) =>
      if reader.isReadingFromDeadLetter()
        notificationCopy = _(_.clone notification)
        .update "subscription", (oldValue) => oldValue.replace reader.deadLetterSuffix, ''
        .value()

        @publish notificationCopy, success: true
