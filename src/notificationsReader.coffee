azure = require("azure")
Promise = require("bluebird")
module.exports =

# Notifications reader from Azure Service Bus.
# config = { connectionString, topic, subscription, options: { log }, filters: [ { name, filter } ] }
class NotificationsReader
  constructor: (@config) ->
    @serviceBusService = Promise.promisifyAll azure.createServiceBusService(@config.connectionString)

  # Start to receive notifications in a *receiver* callback.
  run: (receiver) =>
    @_createSubscription().then => @_receive receiver

  _createSubscription: =>
    (@_do "createSubscription")()
      .then =>
        @_log "subscription created"
        @_addFilters() if @config.filters?
      .catch (e) =>
        itAlreadyExists = e.cause?.code?.toString() is "409"

        if itAlreadyExists then return
        else throw e

  _addFilters: =>
    @_deleteDefaultFilter().then =>
      Promise.all @config.filters.map (filter) => @_createFilter filter

  _deleteDefaultFilter: =>
    (@_do "deleteRule") azure.Constants.ServiceBusConstants.DEFAULT_RULE_NAME
      .then => @_log "default filter removed"
      .catch @_handleError

  _createFilter: ({ name, expression }) =>
    ruleOptions = sqlExpressionFilter: expression
    (@_do "createRule") name, ruleOptions
      .then => @_log "custom filter created"
      .catch @_handleError

  _receive: (receiver) =>
    (@_do "receiveSubscriptionMessage")()
      .then { isPeekLock: true }, (lockedMessage) =>
        @_log "receiving message..."

        receiver @_buildMessage(lockedMessage)
          .then =>
            (@_do "deleteMessage") lockedMessage
              .then => @_log "message processed OK"
              .catch (error) => @_log "error deleting message: #{error}"
          .catch (error) =>
            @_log "error processing message: #{error}"
            (@_do "unlockMessage") lockedMessage

        @_receive receiver
      .catch @_receive receiver

  _buildMessage: (message) ->
    JSON.parse message.body.substring message.body.indexOf "{"

  _do: (funcName) =>
    @serviceBusService["#{funcName}Async"].bind(
      @serviceBusService, @config.topic, @config.subscription
    )

  _handleError: (error) => @_log error if error?
  _log: (info) => console.log info if @config.options?.log
