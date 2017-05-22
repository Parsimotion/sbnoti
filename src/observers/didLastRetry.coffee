RedisObserver = require("./redisObserver")
serializeError = require("serialize-error")

module.exports =
  class DidLastRetry extends RedisObserver

    error: (notification, reader, error) =>
      error = serializeError error
      reader.getMaxDeliveryCount()
      .then (maxDeliveryCount) =>
        if notification.message.brokerProperties.DeliveryCount >= maxDeliveryCount
          @publish notification, { success: false, error: error or "unknown error" }

    _buildValue_: (value, { message: { brokerProperties: { MessageId } } }) =>
      JSON.stringify { value, message: MessageId }
