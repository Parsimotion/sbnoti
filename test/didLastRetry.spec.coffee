require("./helpers/mockedRedis")
{ redis, notification, retryableNotification } = require("./helpers/fixture")
DidLastRetry = require("../src/observers/didLastRetry")
{ observer,mockReader } = {}
should = require("should")
Promise = require("bluebird")

describe "Did Last Retry observer", ->
  beforeEach ->
    mockReader = getMaxDeliveryCount: -> Promise.resolve 10
    observer = new DidLastRetry redis

  it "should publish if a failed mesasge is on its last retry", ->
    error = "hubo un error"
    observer.error notification, mockReader, error
    .then =>
      observer
      .redis.spies.publishAsync
      .withArgs "health-message-sb/una-app/123/un-topic/una-subscription/456", JSON.stringify { value: {"success":false,"error":"hubo un error"}, message: 'el-message-id' }
      .calledOnce.should.be.true()

  it "should not publish if a failed mesasge is not on its last retry", ->
    observer.error retryableNotification, mockReader
    .then =>
      observer
      .redis.spies.publishAsync
      .notCalled.should.be.true()

