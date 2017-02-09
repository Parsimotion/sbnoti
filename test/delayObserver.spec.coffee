require("./helpers/mockedRedis")
{ redis, notification } = require("./helpers/fixture")
DelayObserver = require("../src/observers/delay/delayObserver")
{ huge } = require("../src/observers/delay/delays")
{ observer } = {}
should = require("should")

describe "Delay observer", ->
  beforeEach ->
    observer = new DelayObserver redis

  it "should publish if delay changes", ->
    observer.handle notification
    .then =>
      observer
      .redis.spies.publishAsync
      .withArgs "health-queue/una-app/123/un-topic/una-subscription/456", '"Huge"'
      .calledOnce.should.eql true

  it "should not publish if a non dead letter message runs successfully", ->
    observer.currentDelay = huge
    observer.handle notification
    .then =>
      observer
      .redis.spies.publishAsync
      .notCalled.should.eql true
