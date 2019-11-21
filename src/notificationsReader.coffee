_ = require("lodash")
{ ServiceBusClient, ReceiveMode, delay } = require("@azure/service-bus")

Promise = require("bluebird")
http = require("./services/http")
DEAD_LETTER_SUFFIX = "/$DeadLetterQueue"
debug = require("debug") "sbnoti:reader"
{ Buffer } = require("buffer")

module.exports =

# Notifications reader from Azure Service Bus.
# config = See README
class NotificationsReader

  constructor: (@config) ->
    _.assign @, { http }

  isReadingFromDeadLetter: => @config.deadLetter

  #Gets the max delivery count of a subscription
  getMaxDeliveryCount: =>
    throw new "not implemented"

  # Starts to receive notifications and makes given http request with every received message.
  runAndRequest: (messageToOptions, method, options) =>
    @run http.process messageToOptions, method, options
  
  # Starts to receive notifications and calls the given function with every received message.
  # processMessage: (parsedMessageBody, message) -> promise
  run: (processor) =>
    client = @_createSubscriptionClient().createReceiver(ReceiveMode.peekLock)
    client.registerMessageHandler(@onMessage(processor), @onError, {
      autoComplete: false
      maxConcurrentCalls: @config.concurrency
    })

  onMessage: (processor) -> (brokeredMessage) =>
    { message, context } = @notificationMessage brokeredMessage

    debug "Received %s message from %s/%s", context.bindingData.messageId, @config.topic, @_subscriptionName()
    Promise.resolve(processor(message.body, context))
    .tap => @_notifySuccess message
    .tap => brokeredMessage.complete()
    .tap => debug "Message %s processed OK.", context.bindingData.messageId
    .tapCatch (err) => @_notifyError message, err
    .tapCatch (err) => debug "Message %s processed with errors %o", context.bindingData.messageId, err
    .tapCatch => 
      unless @isReadingFromDeadLetter()
        debug "Abandoning message %s", context.bindingData.messageId
        brokeredMessage.abandon()
    .finally => @_notifyFinish message

  onError: (err) => debug "An error has ocurred %o", err

  notificationMessage: (brokeredMessage) =>
    sanitizedMessage = 
      _(brokeredMessage)
      .omitBy((value, key) => _.startsWith(key, "_"))
      .omit("delivery")
      .update("body", @_sanitizedBody)
      .value()

    {
      message: sanitizedMessage
      context: {
        customProperties: sanitizedMessage.userProperties
        bindingData: _.omit(sanitizedMessage, "userProperties", "body")
      }
    }

  _createSubscriptionClient: =>
    return @serviceBusService.createSubscriptionClient @config.topic, @_subscriptionName()

  _notifyError: (message, error) => @_notify @statusObservers, message, "error", error
  _notifySuccess: (message) => @_notify @statusObservers, message, "success"
  _notifyFinish: (message) => @_notify @finishObservers, message, "finish"

  _buildNotification: (message) =>
    _.merge { message }, _.pick @config, ["app","topic","subscription"]

  _notify: (observers, message, event, opts) =>
    notification = @_buildNotification message
    observers.forEach (observer) => observer[event] notification, @, opts

  _sanitizedBody: (body) ->
    # The messages come with shit before the "{" that breaks JSON.parse =|
    # Example: @strin3http://schemas.microsoft.com/2003/10/Serialization/p{"Changes":[{"Key":
    # ... (rest of the json) ... *a bunch of non printable characters*
    return body unless body instanceof Buffer

    cleanedBody = body
      .toString()
      .substring body.indexOf('{"')
      .replace /[^\x20-\x7E]+/g, ""

    JSON.parse cleanedBody

  _subscriptionName: =>
    suffix = if @isReadingFromDeadLetter() then DEAD_LETTER_SUFFIX else ""
    @config.subscription + suffix

  _handleError: (error) => debug error if error?
  