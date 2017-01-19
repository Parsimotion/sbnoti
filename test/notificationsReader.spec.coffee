mockAzure = require("../test/helpers/mockedAzure")()
{ basicConfig, deadLetterConfig, filtersConfig } = require("../test/helpers/fixture")

should = require("should")
sinon = require("sinon")
_ = require("lodash")
NotificationsReader = require("../src/notificationsReader")
reader = null
describe "NotificationsReader", ->

  beforeEach ->
    reader = (config = basicConfig) => new NotificationsReader config
    mockAzure.refreshSpies()


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

  it "should create a subscription", ->
    reader()._createSubscription()
    .then =>
      mockAzure.spies.createSubscription
      .withArgs "un-topic","una-subscription"
      .calledOnce.should.eql true

  it "should add filter to subscription", ->
    reader(filtersConfig)._createSubscription()
    .then =>
      mockAzure.spies.deleteRule.calledOnce.should.eql true
      mockAzure.spies.createSubscription.calledOnce.should.eql true
      mockAzure.spies.createRule
      .withArgs "un-topic","una-subscription","un-filtro", { sqlExpressionFilter: 'un_filtro eq \'True\'' }
      .calledOnce.should.eql true

