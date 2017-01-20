proxyquire = require("proxyquire")
redisFixture = include("specHelpers/redisFixture")
Promise = require("bluebird")
_ = require("lodash")

module.exports = ->
  class MockRedisClient
    auth: ->
    smembersAsync: (key) -> Promise.resolve redisFixture[key]
    sdiffAsync: (key,otherKey) ->
      Promise.resolve _.difference redisFixture[key], redisFixture[otherKey]

  stub =
    "../services/redis":
      class MockRedis
        @createClient: -> new MockRedisClient()

  proxyquire("../src/observers/redisObserver", stub)

