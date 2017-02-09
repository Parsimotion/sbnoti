_ = require("lodash")
azure = require("azure")
async = require("async")
Promise = require("bluebird")
DidLastRetry = require("./observers/didLastRetry")
DeadLetterSucceeded = require("./observers/deadLetterSucceeded")
DelayObserver = require("./observers/delay/delayObserver")
NotificationsReader = require("./notificationsReader")
CompositeReader = require("./compositeReader")

module.exports =

# Notifications reader from Azure Service Bus.
# config = See README
class NotificationsReaderBuilder

  constructor: ->
    @config =
      concurrency: 25
      waitForMessageTime: 3000
      receiveBatchSize: 5
      log: false
    @activeReaders = pending: true

  _getReader: => new CompositeReader @_getSbnotis()

  _getSbnotis: =>
    sbnotis = []
    { pending, failed } = @activeReaders
    sbnotis.push false if pending
    sbnotis.push true if failed
    sbnotis.map @_getSbnoti

  _getSbnoti: (deadLetter) =>
    reader = new NotificationsReader _.merge {}, @config, { deadLetter }
    _.assign reader, serviceBusService: Promise.promisifyAll(
      azure.createServiceBusService @config.connectionString
    )
    __addObservers = (key) =>
      _.assign reader, "#{key}": @config[key] or []
    __addObservers 'statusObservers'
    __addObservers 'finishObservers'

  build: =>
    @_validateRequired()
    @_getReader()

  activeFor: (@activeReaders = {}) => @

  withConfig: (config) => #Manual config, nice for testing purposes
    @_assignAndReturnSelf config

  withHealth: (config) =>
    { app, redis } = config
    @_assignAndReturnSelf { app }
    @_validateHealthConfig config
    __toRedisObserver = (Observer) => new Observer redis
    @withFinishObservers [ DelayObserver ].map __toRedisObserver
    @withObservers [ DidLastRetry, DeadLetterSucceeded ].map __toRedisObserver
  withFinishObservers: (observers) =>
    @_assignAndReturnSelf finishObservers: _.castArray observers
  withObservers: (observers) =>
    @_assignAndReturnSelf statusObservers: _.castArray observers
  withServiceBus: (serviceBusConfig) =>
    @_assignAndReturnSelf serviceBusConfig
  withFilters: (filters) =>
    @_assignAndReturnSelf { filters }
  withLogging: (log = true) =>
    @_assignAndReturnSelf { log }
  fromDeadLetter: => @activeFor failed: true
  withConcurrency: (concurrency) =>
    @_assignAndReturnSelf { concurrency }
  withReceiveBatchSize: (receiveBatchSize) =>
    @_assignAndReturnSelf { receiveBatchSize }
  withWaitForMessageTime: (waitForMessageTime) =>
    @_assignAndReturnSelf { waitForMessageTime }

  _assignAndReturnSelf: (value) =>
    _.assign @config, value
    @

  _validateHealthConfig: ({redis, app}) =>
    @_validateRedisConfig redis
    throw new Error "Please provide app for health" unless @config.app?

  _validateRedisConfig: (redis) =>
    redisIsComplete = redis.host? and redis.port? and redis.auth? and redis.db?
    throw new Error "Redis incomplete. Please provide host, port, auth and db." unless redisIsComplete

  _validateRequired: =>
    allRequired = @config.topic? and @config.subscription? and @config.connectionString?
    throw new Error "Provide at least topic, subscription and a service bus connectionString." unless allRequired
