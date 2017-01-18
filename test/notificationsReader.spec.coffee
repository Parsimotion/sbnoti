#include("specHelpers/mockedRedis")()
should = require("should")
_ = require("lodash")
NotificationsReader = require("../src/notificationsReader")
reader = null
describe "DealUpdater", ->

  beforeEach ->
    reader = new NotificationsReader { subscription: "una-subscription", deadLetter: false }

  it "should have correct defaults", ->
    reader.config.should.eql subscription: "una-subscription"
