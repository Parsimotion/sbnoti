require("../test/helpers/mockedAzure")()
should = require("should")
_ = require("lodash")
NotificationsReader = require("../src/notificationsReader")
reader = null
describe "DealUpdater", ->

  beforeEach ->
    reader = new NotificationsReader { subscription: "una-subscription", deadLetter: false }

  it "should have correct defaults", ->
    reader.config.should.eql
      subscription: "una-subscription"
      concurrency: 25,
      deadLetter: false,
      log: false,
      receiveBatchSize: 5,
      waitForMessageTime: 3000
