RedisObserver = require("./redisObserver")

module.exports =
  class DeadLetterSucceeded extends RedisObserver

    success: ({ brokerProperties: { MessageId } }, reader) =>
      if reader.isReadingFromDeadLetter()
        @publish "health-message/:app/:userid/resource:", success: true
