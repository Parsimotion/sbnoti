require("./helpers/mockedRedis")
{ redis, notification } = require("./helpers/fixture")
DelayObserver = require("../src/observers/delay/delayObserver")
{ huge } = require("../src/observers/delay/delays")
{ observer } = {}
should = require("should")

describe "Delay observer", ->
  beforeEach ->
    observer = new DelayObserver redis

  it.only "should publish if delay changes", ->
    observer.handle notification
    .then =>
      observer
      .redis.spies.publishAsync
      #.withArgs "health-queue/una-app/123/un-topic/una-subscription/456", JSON.stringify success:true
      .calledOnce.should.eql true

  it "should not publish if a non dead letter message runs successfully", ->
    observer.success notification, mockReader false
    .then =>
      observer
      .redis.spies.publishAsync
      .withArgs "health-message/una-app/123/un-topic/una-subscription/456", JSON.stringify success:true
      .notCalled.should.eql true
