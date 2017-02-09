require("./helpers/mockedRedis")
should = require("should")
moment = require("moment")
DelayObserver = require("../src/observers/delay/delayObserver")
{ redis, notification } = require("./helpers/fixture")
{ minimal, mild, moderate, high, huge } = require("../src/observers/delay/delays")
{ observer } = {}

describe "Delay observer", ->
  beforeEach ->
    observer = new DelayObserver redis

  it "should publish if delay changes", ->
    observer.handle notification
    .then =>
      observer
      .redis.spies.publishAsync
      .withArgs "health-queue/una-app/123/un-topic/una-subscription/456", 'Huge'
      .calledOnce.should.eql true

  it "should not publish if delay did not change", ->
    observer.currentDelay = huge
    observer.handle notification
    .then =>
      observer
      .redis.spies.publishAsync
      .notCalled.should.eql true

  it "should get delay in milliseconds", ->
    enqueuedTime = moment new Date notification.message.brokerProperties.EnqueuedTimeUtc
    now = enqueuedTime.add 100, 'ms'
    delay = observer._millisecondsDelay notification.message, now.toDate()
    delay.should.eql 100

  it "should transform delay in milliseconds to delay object", ->
    assertDelay minimal.value, minimal.name
    assertDelay mild.value, mild.name
    assertDelay moderate.value, moderate.name
    assertDelay high.value, high.name
    assertDelay huge.value, huge.name

assertDelay = (ms, name) =>
  observer._delayByMilliseconds ms
  .name.should.eql name
