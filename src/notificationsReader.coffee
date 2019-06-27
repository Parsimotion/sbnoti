_ = require("lodash")
azure = require("azure")
async = require("async")
Promise = require("bluebird")
http = require("./services/http")
convert = require("convert-units")
DEAD_LETTER_SUFFIX = "/$DeadLetterQueue"
{ Builder } = require "notification-processor"
debug = require("debug") "sbnoti:reader"

highland = require "highland"
require "highland-concurrent-flatmap"

module.exports =

# Notifications reader from Azure Service Bus.
# config = See README
class NotificationsReader

  constructor: (@config) ->
    _.assign @, { http }

  isReadingFromDeadLetter: => @config.deadLetter

  #Gets the max delivery count of a subscription
  getMaxDeliveryCount: =>
    (@_doWithTopic "getSubscription")()
    .then ([subscription]) => subscription?.MaxDeliveryCount or 10

  # Starts to receive notifications and makes given http request with every received message.
  runAndRequest: (messageToOptions, method, options) =>
    @run http.process messageToOptions, method, options
  # Starts to receive notifications and calls the given function with every received message.
  # processMessage: (parsedMessageBody, message) -> promise
  run: (processMessage) =>
    $subscription = if @isReadingFromDeadLetter() then Promise.resolve() else @_createSubscription()
    anyMessage = true
    highland.of 1
    .flatMap -> highland $subscription
    .tap => debug "Listening for messages... %o", { @config }
    .flatMap => 
      highland (push, next) ->
        _push = -> push(null, 1); next()
        if anyMessage
          _push()
        else
          setInterval(_push, @config.waitForMessageTime)
    .concurrentFlatMap @config.receiveBatchSize, => highland @_receive()
    .tap (message) -> anyMessage = message?
    .concurrentFlatMap @config.concurrency, (message) => 
      messageId = message.brokerProperties?.MessageId
      highland(
        processMessage message.body, {
          customProperties: message.customProperties
          bindingData: _.mapKeys(message.brokerProperties, _.camelCase)
        }
        .finally => clearInterval message.interval
        .then (inspection) => (@_do "deleteMessage") message
        .then => debug "--> Message %s processed OK.", messageId
        .catch (err) =>
          debug "--> Message %s processed Failed %o", err
          (@_do "unlockMessage") message unless @isReadingFromDeadLetter()
      )
    .done(_.noop)

  _createSubscription: =>
    (@_doWithTopic "createSubscription")()
      .then =>
        debug "Subscription created!"
        @_addFilters() if @config.filters?
      .catch (e) =>
        itAlreadyExists = e.cause?.code?.toString() is "409"

        if itAlreadyExists then return
        else throw e

  _addFilters: =>
    @_deleteDefaultFilter().then =>
      Promise.all @config.filters.map (filter) => @_createFilter filter

  _deleteDefaultFilter: =>
    (@_doWithTopic "deleteRule") azure.Constants.ServiceBusConstants.DEFAULT_RULE_NAME
      .then => debug "Default filter removed!"
      .catch @_handleError

  _createFilter: ({ name, expression }) =>
    ruleOptions = sqlExpressionFilter: expression
    (@_doWithTopic "createRule") name, ruleOptions
      .then => debug "Custom filter created!"
      .catch @_handleError

  _receive: =>
    (@_doWithTopic "receiveSubscriptionMessage") { isPeekLock: true }
      .spread @_process

  _process: (lockedMessage) =>
    messageId = lockedMessage.brokerProperties?.MessageId
    lockedMessage.body = @_sanitizedBody lockedMessage
    debug "Receiving message... %s", messageId

    renewLock = =>
      debug "renewLock %s", messageId
      (@_do "renewLockForMessage")(lockedMessage)

    _.assign lockedMessage, { interval: setInterval renewLock, convert(30).from('s').to 'ms' }

  _notifyError: (message, error) => @_notify @statusObservers, message, 'error', error

  _notifySuccess: (message) => @_notify @statusObservers, message, 'success'

  _notifyFinish: (message) =>
    @_notify @finishObservers, message, 'finish'

  _buildNotification: (message) =>
    _.merge { message }, _.pick @config, ["app","topic","subscription"]

  _notify: (observers, message, event, opts) =>
    notification = @_buildNotification message
    observers.forEach (observer) => observer[event] notification, @, opts

  _sanitizedBody: (message) ->
    clean = (body) =>
      # The messages come with shit before the "{" that breaks JSON.parse =|
      # Example: @strin3http://schemas.microsoft.com/2003/10/Serialization/p{"Changes":[{"Key":
      # ... (rest of the json) ... *a bunch of non printable characters*
      body
        .substring body.indexOf('{"')
        .replace /[^\x20-\x7E]+/g, ""

    try
      return JSON.parse clean(message.body)
    catch
      debug "ERROR BUILDING THE MESSAGE:\n", message.body

  _do: (funcName) =>
    @serviceBusService["#{funcName}Async"]
      .bind @serviceBusService

  _doWithTopic: (funcName) =>
    suffix = if @isReadingFromDeadLetter() then DEAD_LETTER_SUFFIX else ""
    @_do funcName
      .bind @serviceBusService, @config.topic, @config.subscription + suffix

  _handleError: (error) => debug error if error?
  