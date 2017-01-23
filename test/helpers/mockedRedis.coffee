proxyquire = require("proxyquire")
Promise = require("bluebird")
_ = require("lodash")
sinon = require("sinon")

module.exports = ->
  class MockRedisClient
    constructor: ->
      @refreshSpies()
    auth: ->
    refreshSpies: =>
      @spies = publishAsync: sinon.spy()
    publishAsync: (key,value) ->
      @spies.publishAsync key, value
      Promise.resolve()


  stub =
    "../services/redis":
      class MockRedis
        @createClient: -> new MockRedisClient()
  proxyquire("../../src/observers/redisObserver", stub)

