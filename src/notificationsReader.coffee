azure = require("azure")
Promise = require("bluebird")
async = require("async")
_ = require("lodash")
module.exports =

# Notifications reader from Azure Service Bus.
# config = { connectionString, topic, subscription, options: { log }, filters: [ { name, filter } ], concurrency, waitForMessageTime }
class NotificationsReader
  constructor: (@config) ->
    @serviceBusService = Promise.promisifyAll(
      azure.createServiceBusService @config.connectionString
    )
    _.defaults @config,
      concurrency: 25
      waitForMessageTime: 1000

  # Starts to receive notifications and calls the given function with every received message.
  # processMessage: (message) -> promise
  run: (processMessage) =>
    @_createSubscription().then =>
      @_log "Listening for messages..."
      @_buildQueueWith processMessage
      @_receive()

  _buildQueueWith: (processMessage) =>
    @q = async.queue (message, callback) =>
      response = try processMessage message
      return callback("The receiver didn't returned a Promise.") if not response?.then?
      response
      .then callback
      .catch (err) -> callback(err or "unknown error")
    , @config.concurrency

    @q.empty = @_receive

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
    (_doWithTopic "deleteRule") azure.Constants.ServiceBusConstants.DEFAULT_RULE_NAME
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
      .catch (e) =>
        setTimeout @_receive, @config.waitForMessageTime # (no more messages)

  _process: (lockedMessage) =>
    messageId = lockedMessage.brokerProperties?.MessageId
    @_log "Receiving message... #{messageId}"

    onError = (error) =>
      @_log "--> Error processing message: #{error}. #{messageId}"
      (@_do "unlockMessage") lockedMessage

    @q.push @_buildMessage(lockedMessage), (err) =>
      return onError(err) if err?
      (@_do "deleteMessage") lockedMessage
        .then =>
          @_log "--> Message #{messageId} processed OK."
        .catch (error) =>
          @_log "--> Error deleting message: #{error}. #{messageId}"

  _buildMessage: (message) ->
    clean = (body) =>
      # The messages come with shit before the "{" that breaks JSON.parse =|
      # Example: @strin3http://schemas.microsoft.com/2003/10/Serialization/p{"Changes":[{"Key":
      # ... (rest of the json) ... *a bunch of non printable characters*
      body
        .substring body.indexOf("{")
        .replace /[^\x20-\x7E]+/g, ""

    try
      return JSON.parse clean(message.body)
    catch
      console.log "ERROR BUILDING THE MESSAGE:\n", message.body

  _do: (funcName) =>
    @serviceBusService["#{funcName}Async"]
      .bind @serviceBusService

  _doWithTopic: (funcName) =>
    @_do funcName
      .bind(@serviceBusService, @config.topic, @config.subscription)

  _handleError: (error) => @_log error if error?
  _log: (info) => console.log info if @config.options?.log
