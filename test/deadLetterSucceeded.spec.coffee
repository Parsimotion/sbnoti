require("./helpers/mockedRedis")
{ redis, notification } = require("./helpers/fixture")
DeadLetterSucceeded = require("../src/observers/deadLetterSucceeded")
{ observer } = {}
should = require("should")

describe "Dead Letter Succeeded observer", ->
  beforeEach ->
    observer = new DeadLetterSucceeded redis

  it "should publish if a message runs successfully", ->
    observer.success notification
    .then =>
      observer
      .redis.spies.publishAsync
      .withArgs "health-message-sb/una-app/123/un-topic/una-subscription/456", JSON.stringify success:true
      .calledOnce.should.be.true()
