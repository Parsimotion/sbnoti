_ = require("lodash")
azure = require("azure")
async = require("async")
Promise = require("bluebird")
DidLastRetry = require("./observers/didLastRetry")
DeadLetterSucceeded = require("./observers/deadLetterSucceeded")
NotificationsReader = require("./notificationsReader")

module.exports =

# Notifications reader from Azure Service Bus.
# config = See README
class NotificationsReaderBuilder

  constructor: -> @config = {}

  build: =>
    @_validateRequired()

    _.defaults @config,
      concurrency: 25
      waitForMessageTime: 3000
      receiveBatchSize: 5
      log: false
      deadLetter: false

    reader = new NotificationsReader @config
    _.assign reader, serviceBusService: Promise.promisifyAll(
      azure.createServiceBusService @config.connectionString
    )
    _.assign reader, observers: @config.observers or []


  withConfig: (config) => #Manual config for testing purposes
    @_assignAndReturnSelf config
  withHealth: (redis) =>
    @_validateRedisConfig redis
    @withObservers [ DidLastRetry, DeadLetterSucceeded ].map (Observer) => new Observer redis
  withObservers: (observers) =>
    @_assignAndReturnSelf observers: _.castArray observers
  withServiceBus: (serviceBusConfig) =>
    @_assignAndReturnSelf serviceBusConfig
  withFilters: (filters) =>
    @_assignAndReturnSelf { filters }
  withLogging: (log = true) =>
    @_assignAndReturnSelf { log }
  fromDeadLetter: (deadLetter = true) =>
    @_assignAndReturnSelf { deadLetter }
  withConcurrency: (concurrency) =>
    @_assignAndReturnSelf { concurrency }
  withReceiveBatchSize: (receiveBatchSize) =>
    @_assignAndReturnSelf { receiveBatchSize }
  withWaitForMessageTime: (waitForMessageTime) =>
    @_assignAndReturnSelf { waitForMessageTime }

  _assignAndReturnSelf: (value) =>
    _.assign @config, value
    @

  _validateRedisConfig: (redis) =>
    redisIsComplete = redis.host? and redis.port? and redis.auth? and redis.db?
    throw new Error "Redis incomplete. Please provide host, port, auth and db." unless redisIsComplete

  _validateRequired: =>
    allRequired = @config.topic? and @config.subscription? and @config.connectionString?
    if not _.isEmpty @config.observers
      allRequired = allRequired and @config.app?
    throw new Error "Provide at least topic, subscription and a service bus connectionString" unless allRequired
