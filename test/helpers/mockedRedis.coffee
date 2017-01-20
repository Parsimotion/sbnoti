proxyquire = require("proxyquire")
Promise = require("bluebird")
_ = require("lodash")

module.exports = ->
  class MockRedisClient
    auth: ->
    publishAsync: (key) -> Promise.resolve()


  stub =
    "../services/redis":
      class MockRedis
        @createClient: -> new MockRedisClient()
  proxyquire("../../src/observers/redisObserver", stub)

