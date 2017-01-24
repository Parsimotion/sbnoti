_ = require("lodash")
azure = require("azure")
async = require("async")
Promise = require("bluebird")

DEAD_LETTER_SUFFIX = "/$DeadLetterQueue"
module.exports =

# Notifications reader from Azure Service Bus.
# config = See README
class NotificationsReader

  constructor: (@config) ->

  isReadingFromDeadLetter: => @config.deadLetter

  #Gets the max delivery count of a subscription
  getMaxDeliveryCount: =>
    (@_doWithTopic "getSubscription")()
    .then ([subscription]) => subscription?.MaxDeliveryCount or 10

  # Starts to receive notifications and calls the given function with every received message.
  # processMessage: (parsedMessageBody, message) -> promise
  run: (processMessage) =>
    $subscription = if @isReadingFromDeadLetter() then Promise.resolve() else @_createSubscription()

    $subscription.then =>
      @_log "Listening for messages..."
      @_buildQueueWith processMessage

  _buildQueueWith: (processMessage) =>
    @toReceive = async.queue (___, callback) =>
      @_receive()
        .then callback
        .catch => callback("no messages")
    , @config.concurrency * 2

    @toProcess = async.queue (message, callback) =>
      response = try processMessage @_buildMessage(message), message
      _cleanInterval = -> clearInterval message.interval

      if not response?.then?
        _cleanInterval()
        return callback("The receiver didn't returned a Promise.")

      response
      .then -> callback()
      .catch (err) -> callback(err or "unknown error")
      .finally -> _cleanInterval()

    , @config.concurrency

    setInterval =>
      if @toReceive.length() is 0 and @toProcess.running() is 0
        @toReceive.push 1
    , @config.waitForMessageTime

    receiveChunk = => @toReceive.push [1..@config.receiveBatchSize]
    @toProcess.empty = receiveChunk

    receiveChunk()

  _createSubscription: =>
    (@_doWithTopic "createSubscription")()
      .then =>
        @_log "Subscription created!"
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
      .then => @_log "Default filter removed!"
      .catch @_handleError

  _createFilter: ({ name, expression }) =>
    ruleOptions = sqlExpressionFilter: expression
    (@_doWithTopic "createRule") name, ruleOptions
      .then => @_log "Custom filter created!"
      .catch @_handleError

  _receive: =>
    (@_doWithTopic "receiveSubscriptionMessage") { isPeekLock: true }
      .spread @_process

  _process: (lockedMessage) =>
    messageId = lockedMessage.brokerProperties?.MessageId
    @_log "Receiving message... #{messageId}"

    renewLock = =>
      @_log "renewLock #{messageId}"
      (@_do "renewLockForMessage")(lockedMessage)

    lockedMessage.interval = setInterval renewLock, 1000 * 5

    onError = (error) =>
      @_log "--> Error processing message: #{error}. #{messageId}"
      @_notifyError lockedMessage, error
      (@_do "unlockMessage") lockedMessage unless @isReadingFromDeadLetter()

    @toProcess.push lockedMessage, (err) =>
      return onError(err) if err?
      @_notifySuccess lockedMessage
      (@_do "deleteMessage") lockedMessage
        .then =>
          @_log "--> Message #{messageId} processed OK."
        .catch (error) =>
          @_log "--> Error deleting message: #{error}. #{messageId}"

  _notifyError: (message, error) => @_notify message, 'error', error

  _notifySuccess: (message) => @_notify message, 'success'

  _notify: (message, event, opts) =>
    notification = _.merge { message }, _.pick @config, ["app","topic","subscription"]
    @observers.forEach (observer) => observer[event] notification, @, opts

  _buildMessage: (message) ->
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
      console.log "ERROR BUILDING THE MESSAGE:\n", message.body

  _do: (funcName) =>
    @serviceBusService["#{funcName}Async"]
      .bind @serviceBusService

  _doWithTopic: (funcName) =>
    suffix = if @isReadingFromDeadLetter() then DEAD_LETTER_SUFFIX else ""
    @_do funcName
      .bind @serviceBusService, @config.topic, @config.subscription + suffix

  _handleError: (error) => @_log error if error?
  _log: (info) =>
    console.log info if @config.log
