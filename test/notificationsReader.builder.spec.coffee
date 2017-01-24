mockAzure = require("../test/helpers/mockedAzure")
DidLastRetry = require("../src/observers/didLastRetry")
DeadLetterSucceeded = require("../src/observers/deadLetterSucceeded")
should = require("should")
NotificationsReaderBuilder = require("../src/notificationsReader.builder")
Promise = require("bluebird")
_ = require("lodash")

describe "NotificationsReaderBuilder", ->

  # it "when fully configured, should add health observers", ->
  #   aReader = healthReader()
  #   aReader.observers.forEach (observer) =>
  #     (observer instanceof DidLastRetry or
  #     observer instanceof DeadLetterSucceeded)
  #     .should.eql true

  # it "when not fully configured, should not add health observers", ->
  #   reader().observers.should.eql [ ]
