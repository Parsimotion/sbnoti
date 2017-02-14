require("./helpers/mockedRedis")
should = require("should")
moment = require("moment")
DelayObserver = require("../src/observers/delay/delayObserver")
{ redis, notification } = require("./helpers/fixture")
{ minimal, mild, moderate, high, huge } = require("../src/observers/delay/delayLevels")
{ observer } = {}

describe "Delay observer", ->
  beforeEach ->
    observer = new DelayObserver redis

  it "should publish if delay changes", ->
    observer.finish notification
    .then =>
      observer
      .redis.spies.publishAsync
      .withArgs "health-queue-sb/una-app/123/un-topic/una-subscription/456", 'Huge'
      .calledOnce.should.be.true()

  it "should not publish if delay did not change", ->
    observer.currentDelay = huge
    observer.finish notification
    .then =>
      observer
      .redis.spies.publishAsync
      .notCalled.should.be.true()

  it "should get delay in milliseconds", ->
    enqueuedTime = moment new Date notification.message.brokerProperties.EnqueuedTimeUtc
    now = enqueuedTime.add 100, 'ms'
    delay = observer._millisecondsDelay notification.message, now.toDate()
    delay.should.eql 100

  it "should transform delay in milliseconds to delay object", ->
    anotherMinimal = { value: 10, name: minimal.name }
    anotherMild = { value: 8000, name: mild.name }
    [ minimal, anotherMinimal, mild, anotherMild, moderate, high, huge ].forEach (level) =>
      assertDelay level.value, level.name

assertDelay = (ms, name) =>
  observer._delayByMilliseconds ms
  .name.should.eql name
