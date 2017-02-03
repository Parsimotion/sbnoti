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
    .build().sbnotis[0]
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
      .build().sbnotis[0]
      .observers.forEach (observer) =>
        (observer instanceof DidLastRetry or
        observer instanceof DeadLetterSucceeded)
        .should.eql true

    it "should throw if health is not fully configured", ->
      builder
      .withServiceBus basicConfig
      .withHealth.should.throw()

  describe "Process both regular and dead letter messages", ->
    describe "when it should process both", ->
      it "should build reader with two sbnotis", ->
        builder
        .withServiceBus basicConfig
        .alsoProcessDeadLetter()
        .build()
        .sbnotis.map ({config: {deadLetter}}) -> { deadLetter }
        .should.match [{deadLetter: false}, {deadLetter: true}]

      it "should build reader with two sbnotis regardless of deadLetter property", ->
        builder
        .withServiceBus basicConfig
        .alsoProcessDeadLetter()
        .fromDeadLetter()
        .build()
        .sbnotis.map ({config: {deadLetter}}) -> { deadLetter }
        .should.match [{deadLetter: true}, {deadLetter: false}]

    describe "when it should not process both", ->
      it "should build reader with only one sbnoti", ->
        builder
        .withServiceBus basicConfig
        .build()
        .sbnotis.should.have.length 1
