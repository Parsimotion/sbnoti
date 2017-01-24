proxyquire = require("proxyquire")
Promise = require("bluebird")
_ = require("lodash")
sinon = require("sinon")

class MockRedisClient
  constructor: ->
    @refreshSpies()
  auth: ->
  refreshSpies: =>
    @spies = publishAsync: sinon.spy()
  publishAsync: (key,value) ->
    Promise.resolve @spies.publishAsync key, value

stub =
  "../services/redis":
    class MockRedis
      @createClient: -> new MockRedisClient()
proxyquire("../../src/observers/redisObserver", stub)

