require("./helpers/mockedRedis")
{ redis, notification } = require("./helpers/fixture")
DeadLetterSucceeded = require("../src/observers/deadLetterSucceeded")
{ observer,mockReader } = {}
should = require("should")

describe "Dead Letter Succeeded observer", ->
  beforeEach ->
    mockReader = (deadLetter = true) -> isReadingFromDeadLetter: -> deadLetter
    observer = new DeadLetterSucceeded redis

  it "should publish if a dead letter message runs successfully", ->
    observer.success notification, mockReader()
    .then =>
      observer
      .redis.spies.publishAsync
      .withArgs "health-message/una-app/123/un-topic/una-subscription/456", JSON.stringify success:true
      .calledOnce.should.be.true()

  it "should not publish if a non dead letter message runs successfully", ->
    observer.success notification, mockReader false
    .then =>
      observer
      .redis.spies.publishAsync
      .withArgs "health-message/una-app/123/un-topic/una-subscription/456", JSON.stringify success:true
      .notCalled.should.be.true()
