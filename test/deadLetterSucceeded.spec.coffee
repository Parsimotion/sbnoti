DeadLetterSucceeded = require("../src/observers/deadLetterSucceeded")

describe "Dead Letter Succeeded observer", ->

  # it "should not publish if it runs with error", (done) ->
  #   aReader = healthReader deadLetter: true
  #   assertAfterProcess done, {
  #     message: retryableMessage
  #     process: Promise.reject
  #     assertion: ->
  #       _(aReader.observers).find (it) => it instanceof DeadLetterSucceeded
  #       .redis.spies.publishAsync
  #       .called.should.eql false
  #   }, healthReader

  # it "should publish if it runs successfully", (done) ->
  #   assertAfterProcess done, {
  #     message
  #     process: Promise.resolve
  #     assertion: ->
  #       _(aReader.observers).find (it) => it instanceof DeadLetterSucceeded
  #       .redis.spies.publishAsync
  #       .withArgs "health-message/una-app/123/un-topic/una-subscription/456", JSON.stringify success:true
  #       .callCount.should.eql 1
  #   }, healthReader deadLetter: true
