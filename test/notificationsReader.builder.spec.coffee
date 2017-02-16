mockAzure = require("../test/helpers/mockedAzure")
{ basicConfig } = require("../test/helpers/fixture")
DidLastRetry = require("../src/observers/didLastRetry")
DeadLetterSucceeded = require("../src/observers/deadLetterSucceeded")
DelayObserver = require("../src/observers/delay/delayObserver")
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
    .build()._sbnotis[0]
    .config.should.eql
      subscription: 'una-subscription',
      topic: 'un-topic',
      connectionString: 'un-connection-string',
      concurrency: 25,
      waitForMessageTime: 3000,
      receiveBatchSize: 5,
      log: false,
      deadLetter: false

  it "should build a notification reader deadLetter", ->
    sbnotis = builder
    .withServiceBus basicConfig
    .fromDeadLetter()
    .build()._sbnotis

    onlyOne sbnotis, deadLetter: true

  describe "When health is requested", ->

    it "should add health observers if health fully configured", ->
      reader = builder
      .withServiceBus basicConfig
      .withHealth
        redis:
          host: "host"
          port: 6739
          auth: "asdf"
          db: 2
        app: "la-aplicacion-que-esta-usando-sbnoti"
      .build()._sbnotis[0]

      reader.statusObservers.forEach (observer) =>
        (observer instanceof DidLastRetry or
        observer instanceof DeadLetterSucceeded)
        .should.be.true()
      reader.finishObservers.forEach (observer) =>
        observer.should.be.an.instanceof DelayObserver

    describe "When using strict health mode", ->
      it "should throw if health is not fully configured", ->
        healthWithNoData = ->
          builder
          .withServiceBus basicConfig
          .withHealth strict: true

        healthWithNoData.should.throw()

      it "should throw if no app is provided", ->
        healthWithoutApp = =>
          builder
          .withServiceBus basicConfig
          .withHealth
            redis:
              host: "host"
              port: 6739
              auth: "asdf"
              db: 2
            strict: true

        healthWithoutApp.should.throw()

      it "should throw if redis is incomplete", ->
        healthWithIncompleteRedis = =>
          builder
          .withServiceBus basicConfig
          .withHealth
            redis:
              host: "host"
              port: 6739
            strict: true
        healthWithIncompleteRedis.should.throw()

    describe "When not using strict health mode", ->

      it "should not add status observers if health is not fully configured", ->
        build = builder
        .withServiceBus basicConfig
        .withHealth {}
        shouldBuildWithoutStatusObservers build

      it "should not add status observers if no app is provided", ->
        build = builder
        .withServiceBus basicConfig
        .withHealth
          redis:
            host: "host"
            port: 6739
            auth: "asdf"
            db: 2
        shouldBuildWithoutStatusObservers build

      it "should not add status observers if redis is incomplete", ->
        build = builder
          .withServiceBus basicConfig
          .withHealth
            redis:
              host: "host"
              port: 6739
        shouldBuildWithoutStatusObservers build

  describe "With explicit activeFor call", ->
    it "should build reader with two sbnotis", ->
      sbnotis = builder
      .activeFor
        pending: true
        failed: true
      ._getSbnotis()
      sbnotis.should.have.length 2
      readsFromDeadLetter(sbnotis[0]).should.be.false()
      readsFromDeadLetter(sbnotis[1]).should.be.true()

    it "should build reader with only a regular sbnoti", ->
      sbnotis = builder
      .activeFor
        pending: true
      ._getSbnotis()
      onlyOne sbnotis, deadLetter: false

    it "should build reader with only a deadLetter sbnoti", ->
      sbnotis = builder
      .activeFor
        failed: true
      ._getSbnotis()
      onlyOne sbnotis, deadLetter: true

    it "should build reader withouts sbnotis if nothing is passed", ->
      sbnotis = builder
      .activeFor()
      ._getSbnotis()
      sbnotis.should.have.length 0

    it "should build reader without sbnotis if options are false", ->
      sbnotis = builder
      .activeFor
        failed: false
        pending: false
      ._getSbnotis()
      sbnotis.should.have.length 0

    it "should build one regular reader ", ->
      sbnotis = builder
      .activeFor
        pending: true
        failed: false
      ._getSbnotis()
      onlyOne sbnotis, deadLetter: false

    it "should build one deadletter reader", ->
      sbnotis = builder
      .activeFor
        pending: false
        failed: true
      ._getSbnotis()
      onlyOne sbnotis, deadLetter: true

  describe "Without explicit activeFor call", ->
    it "should default to one regular sbnoti", ->
      sbnotis = builder._getSbnotis()
      onlyOne sbnotis, deadLetter: false

onlyOne = (sbnotis, { deadLetter }) ->
  sbnotis.should.have.length 1
  readsFromDeadLetter(sbnotis[0]).should.eql deadLetter

readsFromDeadLetter = (sbnoti) -> sbnoti.config.deadLetter

shouldBuildWithoutStatusObservers = (builder) ->
  _.head(builder.build()._sbnotis).statusObservers.should.have.length 0
