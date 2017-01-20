RedisObserver = require("./redisObserver")

module.exports =
  class DidLastRetry extends RedisObserver

    error: (message, error) =>
      @reader.getMaxDeliveryCount()
      .then (maxDeliveryCount) =>
        if message.brokerProperties.DeliveryCount > maxDeliveryCount
          @publish message, { success: false, error }

