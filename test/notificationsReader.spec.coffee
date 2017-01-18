require("../test/helpers/mockedAzure")()
{ basicConfig, deadLetterConfig, filtersConfig } = require("../test/helpers/fixture")

should = require("should")
_ = require("lodash")
NotificationsReader = require("../src/notificationsReader")
reader = null
describe "NotificationsReader", ->

  beforeEach ->
    reader = (config = basicConfig) => new NotificationsReader config

  it "should have correct defaults", ->
    reader().config.should.eql
      subscription: "una-subscription"
      topic: "un-topic"
      concurrency: 25,
      deadLetter: false,
      log: false,
      receiveBatchSize: 5,
      waitForMessageTime: 3000

  it "should subscribe to dead letter", ->
    reader(deadLetterConfig).config.subscription
    .should.eql "una-subscription/$DeadLetterQueue"

  it "should create subscription", ->
    reader(filtersConfig)._createSubscription()

  it.only "should add filter to subscription", ->
    reader(filtersConfig)._createSubscription()
