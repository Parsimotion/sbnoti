RedisObserver = require("./redisObserver")

module.exports =
  class DidLastRetry extends RedisObserver

    error: (notification, reader, error) =>
      reader.getMaxDeliveryCount()
      .then (maxDeliveryCount) =>
        if notification.message.brokerProperties.DeliveryCount >= maxDeliveryCount
          @publish notification, { success: false, error: error?.toString?() or "unknown error" }

    _buildValue_: (rawValue, { message: { brokerProperties: { MessageId } } }) =>
      value = super rawValue
      JSON.stringify { value, message: MessageId }
