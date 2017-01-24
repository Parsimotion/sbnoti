DidLastRetry = require("../src/observers/didLastRetry")

describe "Did Last Retry observer", ->

  # it "should publish on error if last retry", (done) ->
  #   aReader = healthReader()
  #   assertAfterProcess done, {
  #     message
  #     process: Promise.reject
  #     assertion: ->
  #       _(aReader.observers).find (it) => it instanceof DidLastRetry
  #       .redis.spies.publishAsync
  #       .withArgs "health-message/una-app/123/un-topic/una-subscription/456", JSON.stringify {"success":false,"error":{"un":"json","CompanyId":123,"ResourceId":456}}
  #       .callCount.should.eql 1
  #   }, aReader

  # it "should not publish on error if it is not the last retry", (done) ->
  #   aReader = healthReader()
  #   assertAfterProcess done, {
  #     message: retryableMessage
  #     process: Promise.reject
  #     assertion: ->
  #       _(aReader.observers).find (it) => it instanceof DidLastRetry
  #       .redis.spies.publishAsync
  #       .called.should.eql false
  #   }, aReader

  # it "should not publish if it runs successfully", (done) ->
  #   aReader = healthReader()
  #   assertAfterProcess done, {
  #     message: retryableMessage
  #     process: Promise.resolve
  #     assertion: ->
  #       _(aReader.observers).find (it) => it instanceof DidLastRetry
  #       .redis.spies.publishAsync
  #       .called.should.eql false
  #   }, aReader
