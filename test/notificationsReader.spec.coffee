require("../test/helpers/mockedAzure")()
{ aConfig, deadLetterConfig } = require("../test/helpers/fixture")

should = require("should")
_ = require("lodash")
NotificationsReader = require("../src/notificationsReader")
reader = null
describe "DealUpdater", ->

  beforeEach ->
    reader = (config = aConfig) => new NotificationsReader config

  it "should have correct defaults", ->
    reader().config.should.eql
      subscription: "una-subscription"
      concurrency: 25,
      deadLetter: false,
      log: false,
      receiveBatchSize: 5,
      waitForMessageTime: 3000

  it "should subscribe to dead letter", ->
    reader(deadLetterConfig).config.subscription.should.eql "una-subscription/$DeadLetterQueue"
