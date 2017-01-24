mockAzure = require("../test/helpers/mockedAzure")
{ basicConfig } = require("../test/helpers/fixture")
DidLastRetry = require("../src/observers/didLastRetry")
DeadLetterSucceeded = require("../src/observers/deadLetterSucceeded")
should = require("should")
NotificationsReaderBuilder = require("../src/notificationsReader.builder")
Promise = require("bluebird")
_ = require("lodash")

builder = null

describe "NotificationsReaderBuilder", ->
  beforeEach ->
    builder = new NotificationsReaderBuilder()

  it "should throw if not fully configured", ->
    builder.build.should.throw()

  it "should build a notification reader with proper config", ->
    builder
    .withServiceBus basicConfig
    .build()
    .config.should.eql
      subscription: 'una-subscription',
      topic: 'un-topic',
      app: 'una-app',
      connectionString: 'un-connection-string',
      concurrency: 25,
      waitForMessageTime: 3000,
      receiveBatchSize: 5,
      log: false,
      deadLetter: false


  describe "When health is requested", ->

    it "should add health observers if health fully configured", ->
      builder
      .withServiceBus basicConfig
      .withHealth
        host: "host"
        port: 6739
        auth: "asdf"
        db: 2
      .build()
      .observers.forEach (observer) =>
        (observer instanceof DidLastRetry or
        observer instanceof DeadLetterSucceeded)
        .should.eql true

    it "should throw if health is not fully configured", ->
      builder
      .withServiceBus basicConfig
      .withHealth.should.throw()
