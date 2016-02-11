azure = require("azure")
Promise = require("bluebird")
module.exports =

# Notifications reader from Azure Service Bus.
# config = { connectionString, topic, subscription, options: { log }, filters: [ { name, filter } ] }
class NotificationsReader
  constructor: (@config) ->
    @serviceBusService = Promise.promisifyAll(
      azure.createServiceBusService @config.connectionString
    )

  # Start to receive notifications in a *receiver* callback.
  run: (receiver) =>
    @_createSubscription().then =>
      @_log "Listening for messages..."
      @_receive receiver

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

  _receive: (receiver) =>
    (@_doWithTopic "receiveSubscriptionMessage") { isPeekLock: true }
      .spread (lockedMessage) =>
        @_log "Receiving message..."

        onError = (error) =>
          @_log "--> Error processing message: #{error}."
          (@_do "unlockMessage") lockedMessage

        response = try receiver @_buildMessage(lockedMessage)
        if response?.then?
          response
            .then =>
              (@_do "deleteMessage") lockedMessage
                .then =>
                  @_log "--> Message processed OK."
                .catch (error) =>
                  @_log "--> Error deleting message: #{error}."
            .catch (data) =>
              onError(data)
            .finally =>
              @_receive receiver
        else
          onError "The receiver didn't returned a Promise."
          @_receive receiver
      .catch (e) => @_receive receiver # (no more messages)

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
