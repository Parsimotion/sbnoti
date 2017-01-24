mockAzure = require("../test/helpers/mockedAzure")
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

  it "should throw if not fully configured", (done)->
    try
      builder.build()
    catch
      done()

  describe "When health is requested", ->

    it "should add health observers if fully configured", ->
      builder
      .withServiceBus
        connectionString: "un connection string"
        topic: "un topic"
        subscription: "una subscription"
        app: "una app"
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
