RedisObserver = require("./redisObserver")

module.exports =
  class DidLastRetry extends RedisObserver

      error: (message, reader, error) =>
        reader.getMaxDeliveryCount()
        .then (maxDeliveryCount) =>
          if message.brokerProperties.DeliveryCount > maxDeliveryCount
            @publish "health-message/:app/:userid/resource:", { success: false, error }

